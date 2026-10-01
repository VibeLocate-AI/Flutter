import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/my_properties_controller.dart';
import '../../../home/data/models/property_model.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/localization/localization.dart';
import '../../properties_dependencies.dart';
import '../../../home/presentation/widgets/recommended_property_card.dart';
import 'add_property_page.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends State<PropertiesPage> {
  final TextEditingController _searchController = TextEditingController();

  MyPropertiesController get controller =>
      Get.find<MyPropertiesController>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    controller.initialize();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    controller.setQuery(_searchController.text);
    setState(() {});
  }

  Future<void> _openAddProperty() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => const AddPropertyPage()),
    );
    if (!mounted || (result != true && result is! int)) return;

    // The add screen returns its created property id. Hydrate just that
    // property first so it appears immediately instead of waiting for a
    // complete collection refresh.
    if (result is int && result > 0) {
      try {
        final property = await PropertiesDependencies.getPropertyDetails(result);
        controller.prepend(property);
      } catch (_) {
        controller.reload();
      }
    } else {
      controller.reload();
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
      final error = controller.error.value;
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          sliver: SliverToBoxAdapter(
            child: TextField(
              controller: _searchController,
              onChanged: controller.setQuery,
              decoration: InputDecoration(
                hintText: localization.translate('search_properties'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
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
          padding: const EdgeInsets.only(left: 20, bottom: 14),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _TypeChip(
                    label: localization.translate('property_type_all'),
                    selected: controller.selectedTypeId.value == null,
                    onTap: () => controller.setType(null),
                  ),
                  ...List.generate(16, (index) {
                    final typeId = index + 1;
                    return _TypeChip(
                      label: _typeLabel(typeId, localization),
                      selected: controller.selectedTypeId.value == typeId,
                      onTap: () => controller.setType(typeId),
                    );
                  }),
                ],
              ),
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
                    return RecommendedPropertyCard(
                      property: property,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/property-details',
                        arguments: property.id,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _typeLabel(int id, AppLocalization localization) {
    const keys = [
      'property_type_apartment', 'property_type_villa', 'property_type_penthouse', 'property_type_townhouse',
      'property_type_house', 'property_type_office', 'property_type_warehouse', 'property_type_land',
      'property_type_restaurant', 'property_type_hotel', 'property_type_building', 'property_type_commercial_shop',
      'property_type_clinic', 'property_type_school', 'property_type_showroom', 'property_type_cafe',
    ];
    if (id < 1 || id > keys.length) return localization.translate('property_type_all');
    return localization.translate(keys[id - 1]);
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        ),
        selectedColor: theme.colorScheme.primary,
      ),
    );
  }
}
