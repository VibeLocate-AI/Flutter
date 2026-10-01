import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../auth/auth_dependencies.dart';
import '../../../properties/presentation/pages/add_property_page.dart';
import '../../agent_controller.dart';
import '../../data/models/agent_property.dart';

class AgentDashboardPage extends StatefulWidget {
  const AgentDashboardPage({super.key});

  @override
  State<AgentDashboardPage> createState() => _AgentDashboardPageState();
}

class _AgentDashboardPageState extends State<AgentDashboardPage> {
  late final AgentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AgentController>()
        ? Get.find<AgentController>()
        : Get.put(AgentController(), permanent: true);
    if (!controller.hasLoaded.value) {
      controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('agent_dashboard')),
        actions: [
          IconButton(
            tooltip: localization.translate('refresh'),
            onPressed: controller.isLoading.value ? null : controller.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: localization.translate('logout'),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final hasItems = controller.pending.isNotEmpty ||
            controller.approved.isNotEmpty ||
            controller.rejected.isNotEmpty ||
            controller.pois.isNotEmpty;

        if (controller.isLoading.value && !hasItems) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.error.value;
        if (error != null && !hasItems) {
          return _ErrorState(
            message: error,
            retryLabel: localization.translate('try_again'),
            onRetry: controller.load,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              width < 380 ? 14 : 20,
              16,
              width < 380 ? 14 : 20,
              120,
            ),
            children: [
              if (error != null) _InlineError(message: error),
              _SummaryRow(controller: controller),
              const SizedBox(height: 18),
              _PropertySection(
                title: localization.translate('pending'),
                properties: controller.pending,
                actionBuilder: (property) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: localization.translate('approved'),
                      onPressed: () => controller.approve(property.id),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                    ),
                    IconButton(
                      tooltip: localization.translate('rejected'),
                      onPressed: () => controller.reject(property.id),
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  ],
                ),
              ),
              _PropertySection(
                title: localization.translate('approved'),
                properties: controller.approved,
              ),
              _PropertySection(
                title: localization.translate('rejected'),
                properties: controller.rejected,
              ),
              const SizedBox(height: 12),
              _PoiSection(
                title: localization.translate('agent_pois'),
                pois: controller.pois,
                onAdd: _openAddPoi,
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _openAddProperty,
                icon: const Icon(Icons.add_rounded),
                label: Text(localization.translate('add_property')),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _openAddProperty() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPropertyPage()),
    );
    await controller.load();
  }

  Future<void> _openAddPoi() async {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    final localization = AppLocalization.of(context);
    try {
      final submit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localization.translate('agent_add_place')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: localization.translate('agent_place_name'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: localization.translate('agent_place_type'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: latController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: localization.translate('agent_latitude'),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lngController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: localization.translate('agent_longitude'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localization.translate('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(localization.translate('save')),
            ),
          ],
        ),
      );

      if (submit != true) return;

      final name = nameController.text.trim();
      final type = typeController.text.trim();
      final latitude = double.tryParse(latController.text.trim());
      final longitude = double.tryParse(lngController.text.trim());

      if (name.isEmpty || type.isEmpty || latitude == null || longitude == null) {
        if (mounted) {
          _showMessage(localization.translate('complete_required_fields'));
        }
        return;
      }

      await controller.createPoi({
        'name': name,
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (mounted) {
        _showMessage(localization.translate('agent_add_place_success'));
      }
    } finally {
      nameController.dispose();
      typeController.dispose();
      latController.dispose();
      lngController.dispose();
    }
  }

  Future<void> _logout() async {
    try {
      await AuthDependencies.logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.controller});

  final AgentController controller;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final items = [
      (localization.translate('pending'), controller.pending.length),
      (localization.translate('approved'), controller.approved.length),
      (localization.translate('rejected'), controller.rejected.length),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                children: [
                  Text(
                    '${item.$2}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PropertySection extends StatelessWidget {
  const _PropertySection({
    required this.title,
    required this.properties,
    this.actionBuilder,
  });

  final String title;
  final List<AgentProperty> properties;
  final Widget Function(AgentProperty property)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${properties.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        if (properties.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(
              AppLocalization.of(context).translate('agent_empty'),
              style: theme.textTheme.bodySmall,
            ),
          )
        else
          ...properties.take(12).map(
                (property) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: _PropertyImage(url: property.imageUrl),
                    title: Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      property.address.isEmpty
                          ? property.price
                          : property.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: actionBuilder?.call(property),
                    onTap: property.id == 0
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              AppRouter.propertyDetails,
                              arguments: property.id,
                            ),
                  ),
                ),
              ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (url.isEmpty) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.home_work_outlined),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.home_work_outlined),
        ),
      ),
    );
  }
}

class _PoiSection extends StatelessWidget {
  const _PoiSection({
    required this.title,
    required this.pois,
    required this.onAdd,
  });

  final String title;
  final List<Map<String, dynamic>> pois;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$title (${pois.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (pois.isEmpty)
          Text(AppLocalization.of(context).translate('agent_empty'))
        else
          ...pois.take(10).map(
                (poi) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(
                    (poi['name'] ?? poi['title'] ?? '').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (poi['type'] ?? poi['category'] ?? '').toString(),
                  ),
                ),
              ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: Text(message),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
