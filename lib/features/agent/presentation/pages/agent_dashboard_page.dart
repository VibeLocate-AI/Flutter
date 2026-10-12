import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../agent_controller.dart';
import '../../data/models/agent_property.dart';
import '../../../properties/presentation/pages/add_property_page.dart';

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
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Refresh Agent data',
              onPressed: controller.isLoading.value ? null : controller.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final hasData = controller.pending.isNotEmpty ||
            controller.approved.isNotEmpty ||
            controller.rejected.isNotEmpty ||
            controller.pois.isNotEmpty;

        if (controller.isLoading.value && !hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
            children: [
              _DashboardHeader(controller: controller),
              const SizedBox(height: 14),
              if (controller.error.value != null) ...[
                _ErrorBanner(message: controller.error.value!),
                const SizedBox(height: 12),
              ],
              _BackendStatusGrid(controller: controller),
              const SizedBox(height: 20),
              _PropertyGroup(
                title: 'Pending Properties',
                status: 'pending',
                properties: controller.pending,
                actions: true,
                onApprove: controller.approve,
                onReject: _reject,
              ),
              _PropertyGroup(
                title: 'Approved Properties',
                status: 'approved',
                properties: controller.approved,
              ),
              _PropertyGroup(
                title: 'Rejected Properties',
                status: 'rejected',
                properties: controller.rejected,
              ),
              _PoiGroup(
                pois: controller.pois,
                onAdd: () => _openPoiEditor(),
                onEdit: _openPoiEditor,
                onDelete: _deletePoi,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _submitLicense,
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Submit Agent License'),
              ),
              const SizedBox(height: 9),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPropertyPage()),
                  );
                  await controller.load();
                },
                icon: const Icon(Icons.add_home_work_rounded),
                label: const Text('Add Property'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _reject(int id) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject property'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Optional rejection reason',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (reason == null) return;
    try {
      await controller.reject(id, reason: reason);
    } catch (e) {
      if (!mounted) return;
      _message(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _submitLicense() async {
    try {
      await controller.submitLicense();
      if (mounted) _message('Agent license submitted successfully.');
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openPoiEditor([Map<String, dynamic>? existing]) async {
    final name = TextEditingController(
      text: (existing?['name'] ?? existing?['title'] ?? '').toString(),
    );
    final category = TextEditingController(
      text: (existing?['category'] ?? existing?['type'] ?? '').toString(),
    );
    final subcategory = TextEditingController(
      text: (existing?['subcategory'] ?? '').toString(),
    );
    final icon = TextEditingController(text: (existing?['icon'] ?? '').toString());
    final latitude = TextEditingController(text: (existing?['latitude'] ?? '').toString());
    final longitude = TextEditingController(text: (existing?['longitude'] ?? '').toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Create Agent POI' : 'Update Agent POI'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(name, 'Name'),
              _dialogField(category, 'Category'),
              _dialogField(subcategory, 'Subcategory'),
              _dialogField(icon, 'Icon'),
              _dialogField(latitude, 'Latitude', number: true),
              _dialogField(longitude, 'Longitude', number: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(existing == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );

    if (saved != true) {
      for (final c in [name, category, subcategory, icon, latitude, longitude]) {
        c.dispose();
      }
      return;
    }

    final body = <String, dynamic>{
      'name': name.text.trim(),
      'category': category.text.trim(),
      'subcategory': subcategory.text.trim(),
      'latitude': double.tryParse(latitude.text.trim()),
      'longitude': double.tryParse(longitude.text.trim()),
      'icon': icon.text.trim(),
    };

    for (final c in [name, category, subcategory, icon, latitude, longitude]) {
      c.dispose();
    }

    try {
      if (existing == null) {
        await controller.createPoi(body);
      } else {
        final id = int.tryParse(
          (existing['id'] ?? existing['osm_id'] ?? '').toString(),
        );
        if (id == null) throw Exception('POI id was not returned by the backend.');
        await controller.updatePoi(id, body);
      }
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deletePoi(Map<String, dynamic> poi) async {
    final id = int.tryParse((poi['id'] ?? poi['osm_id'] ?? '').toString());
    if (id == null) {
      _message('This POI has no backend id.');
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete POI?'),
        content: Text((poi['name'] ?? poi['title'] ?? 'This POI').toString()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes != true) return;

    try {
      await controller.deletePoi(id);
    } catch (e) {
      if (mounted) _message(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.controller});

  final AgentController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_done_rounded, color: theme.colorScheme.primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laravel Agent data',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  'Every property and POI keeps the complete response returned by the backend.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendStatusGrid extends StatelessWidget {
  const _BackendStatusGrid({required this.controller});
  final AgentController controller;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Pending', controller.pending.length, Icons.hourglass_top_rounded),
      ('Approved', controller.approved.length, Icons.check_circle_rounded),
      ('Rejected', controller.rejected.length, Icons.cancel_rounded),
      ('POIs', controller.pois.length, Icons.location_on_rounded),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: values.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 78,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
      ),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(values[i].$3, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${values[i].$2}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text(values[i].$1, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyGroup extends StatelessWidget {
  const _PropertyGroup({
    required this.title,
    required this.status,
    required this.properties,
    this.actions = false,
    this.onApprove,
    this.onReject,
  });

  final String title;
  final String status;
  final List<AgentProperty> properties;
  final bool actions;
  final Future<void> Function(int id)? onApprove;
  final Future<void> Function(int id)? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$title (${properties.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text(status, style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          if (properties.isEmpty)
            _EmptyBox(text: 'No $status properties returned by the backend.')
          else
            ...properties.map(
              (property) => _BackendPropertyCard(
                property: property,
                actions: actions,
                onApprove: onApprove,
                onReject: onReject,
              ),
            ),
        ],
      ),
    );
  }
}

class _BackendPropertyCard extends StatelessWidget {
  const _BackendPropertyCard({
    required this.property,
    required this.actions,
    this.onApprove,
    this.onReject,
  });

  final AgentProperty property;
  final bool actions;
  final Future<void> Function(int id)? onApprove;
  final Future<void> Function(int id)? onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: _PropertyImage(url: property.imageUrl),
        title: Text(
          property.title.isEmpty ? 'Property #${property.id}' : property.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (property.status.isNotEmpty) property.status,
              if (property.price.isNotEmpty) property.price,
              if (property.address.isNotEmpty) property.address,
              '${property.raw.length} backend fields',
            ].join(' • '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: actions
            ? Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    tooltip: 'Approve',
                    onPressed: onApprove == null ? null : () => onApprove!(property.id),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'Reject',
                    onPressed: onReject == null ? null : () => onReject!(property.id),
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                ],
              )
            : null,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Complete backend response',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          if (property.raw.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('The backend returned no extra fields.'),
            )
          else
            ...property.raw.entries.map(
              (entry) => _BackendField(
                keyName: entry.key,
                value: entry.value,
              ),
            ),
        ],
      ),
    );
  }
}

class _BackendField extends StatelessWidget {
  const _BackendField({required this.keyName, required this.value});
  final String keyName;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplex = value is Map || value is List;
    final text = isComplex
        ? const JsonEncoder.withIndent('  ').convert(value)
        : (value == null ? 'null' : value.toString());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(keyName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 3),
          SelectableText(
            text,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: isComplex ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PoiGroup extends StatelessWidget {
  const _PoiGroup({
    required this.pois,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> pois;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Agency POIs (${pois.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add_rounded)),
          ],
        ),
        const SizedBox(height: 7),
        if (pois.isEmpty)
          const _EmptyBox(text: 'No POIs returned by the backend.')
        else
          ...pois.map(
            (poi) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: const CircleAvatar(child: Icon(Icons.place_outlined)),
                title: Text(
                  (poi['name'] ?? poi['title'] ?? 'POI').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  [
                    if ((poi['category'] ?? poi['type'] ?? '').toString().isNotEmpty)
                      (poi['category'] ?? poi['type']).toString(),
                    '${poi.length} backend fields',
                  ].join(' • '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () => onEdit(poi),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () => onDelete(poi),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: poi.entries
                          .map((entry) => _BackendField(keyName: entry.key, value: entry.value))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.home_work_outlined));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const CircleAvatar(child: Icon(Icons.home_work_outlined)),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text),
      );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Refresh issue. Cached Agent data remains visible.\n$message',
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      );
}
