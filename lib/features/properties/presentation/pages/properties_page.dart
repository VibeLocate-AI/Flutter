import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/my_properties_controller.dart';
import '../../../../core/controllers/property_details_controller.dart';
import '../../../home/data/models/property_model.dart';

import '../../../../core/localization/localization.dart';
import '../../../home/presentation/widgets/recommended_property_card.dart';
import '../../../home/presentation/widgets/property_filter_sheet.dart';
import '../../../home/presentation/widgets/property_categories.dart';
import 'add_property_page.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  PropertyFilterValues _filters = const PropertyFilterValues();

  MyPropertiesController get controller =>
      Get.find<MyPropertiesController>();

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  Future<void> _showFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .90,
        child: PropertyFilterSheet(
          initialValues: _filters,
          onApply: (value) {
            setState(() => _filters = value);
            controller.setFilters(value);
          },
        ),
      ),
    );
  }

  Future<void> _openAddProperty() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => const AddPropertyPage()),
    );
    if (!mounted ||
        (result != true && result is! int && result is! Map)) {
      return;
    }

    int? addedId;
    PropertyModel? optimisticProperty;

    if (result is int && result > 0) {
      addedId = result;
    } else if (result is Map) {
      final normalized = result.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final value = normalized['id'] ?? normalized['property_id'];
      addedId = int.tryParse(value?.toString() ?? '');
      try {
        final parsedProperty = PropertyModel.fromJson(normalized);
        optimisticProperty = parsedProperty;
        if (parsedProperty.title.isNotEmpty || parsedProperty.price > 0) {
          controller.prepend(parsedProperty);
        }
      } catch (_) {}
    }

    // /api/my-properties is the authoritative owner collection. Reload it
    // first, then restore the optimistic record if the backend has not exposed
    // the new row yet. This prevents a successful Add Property from appearing
    // to vanish immediately after the request completes.
    await controller.reload();

    if (optimisticProperty != null) {
      final missingById = addedId != null && addedId > 0
          ? !controller.properties.any((property) => property.id == addedId)
          : true;
      if (missingById) {
        controller.prepend(optimisticProperty);
      }
    }

    bool optimisticStillMissing() {
      final optimistic = optimisticProperty;
      if (optimistic == null) return false;
      return !controller.properties.any((property) {
        if (addedId != null && addedId > 0) {
          return property.id == addedId;
        }
        return property.displayTitle.trim() == optimistic.displayTitle.trim() &&
            (optimistic.price <= 0 || (property.price - optimistic.price).abs() < 0.01);
      });
    }

    if (addedId != null && addedId > 0 &&
        !controller.properties.any((property) => property.id == addedId)) {
      const delays = <int>[500, 900, 1400, 2000];
      for (final delay in delays) {
        await Future<void>.delayed(Duration(milliseconds: delay));
        await controller.reload();
        if (controller.properties.any((property) => property.id == addedId)) {
          break;
        }
      }
    } else if (optimisticProperty != null && optimisticStillMissing()) {
      // Some deployments return a success message before returning the new
      // ID. Keep the form data visible while the collection catches up.
      final optimistic = optimisticProperty;
      const delays = <int>[700, 1200, 1800];
      for (final delay in delays) {
        controller.prepend(optimistic);
        await Future<void>.delayed(Duration(milliseconds: delay));
        await controller.reload();
        if (!optimisticStillMissing()) break;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          AppLocalization.of(context).translate('property_added_successfully'),
        ),
      ),
    );
  }

  Future<void> _load() => controller.reload();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    return Obx(() {
      final properties = controller.filtered;
      final loading = controller.isLoading.value;
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
        title: Text(localization.translate('my_properties')),
        actions: [
          IconButton(
            tooltip: localization.translate('add_property'),
            onPressed: _openAddProperty,
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: localization.translate('refresh'),
            onPressed: loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(context, theme, localization, properties),
        ),
      );
    });
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    AppLocalization localization,
    List<PropertyModel> properties,
  ) {
    final loading = controller.isLoading.value;
    if (loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 500, child: Center(child: CircularProgressIndicator()))],
      );
    }

    final error = controller.error.value;
    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .45,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 42, color: theme.colorScheme.error),
                    const SizedBox(height: 12),
                    Text(error, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _load, child: Text(localization.translate('try_again'))),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final bottomNavigationSpace =
        MediaQuery.paddingOf(context).bottom + 156;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: PropertyCategories(
            onCategorySelected: (typeId) {
              controller.setTypeId(typeId);
              _filters = _filters.copyWith(clearCategoryId: true);
              controller.setFilters(_filters);
              setState(() {});
            },
            onMoreFilters: _showFilters,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${properties.length} ${localization.translate('properties')}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _openAddProperty,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(localization.translate('add_property')),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottomNavigationSpace),
          sliver: properties.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 54,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            localization.translate('no_my_properties'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localization.translate('add_first_property'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _openAddProperty,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(localization.translate('add_property')),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: properties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return _MyPropertyCard(
                      property: property,
                      onTap: property.id > 0
                          ? () {
                              Get.find<PropertyDetailsController>().setProperty(property);
                              Navigator.pushNamed(
                                context,
                                '/property-details',
                                arguments: property.id,
                              );
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}


String _humanizeStatus(String value) {
  final normalized = value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .trim();
  if (normalized.isEmpty) return 'Pending';

  return normalized
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}


class _MyPropertyCard extends StatelessWidget {
  const _MyPropertyCard({required this.property, this.onTap});

  final PropertyModel property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final status = property.normalizedApprovalStatus;
    final isPending = status == 'pending' || status.isEmpty;
    final isApproved = status == 'approved';
    final color = isApproved
        ? Colors.green
        : status == 'rejected'
            ? theme.colorScheme.error
            : Colors.orange;
    final label = switch (status) {
      'approved' => localization.translate('approved'),
      'rejected' => localization.translate('rejected'),
      'pending' => localization.translate('pending'),
      _ => _humanizeStatus(status),
    };

    return Stack(
      children: [
        RecommendedPropertyCard(property: property, onTap: onTap),
        PositionedDirectional(
          bottom: 10,
          end: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 2), color: Colors.black26)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved ? Icons.check_circle_rounded : isPending ? Icons.schedule_rounded : Icons.cancel_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
