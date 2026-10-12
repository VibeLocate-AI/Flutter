import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/json_cache_storage.dart';
import '../../agent_controller.dart';

class AgentViewingRequestsPage extends StatelessWidget {
  const AgentViewingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StaticAgentSectionPage(
      title: 'Viewing Requests',
      subtitle: 'Track and confirm property viewing appointments',
      icon: Icons.calendar_month_rounded,
      children: [
        _StatusChips(labels: ['All (3)', 'Pending (2)', 'Confirmed (1)', 'Declined (0)']),
        _RequestCard(name: 'Ahmed Al Mansoori', property: 'The Royal Atlantis Sky Villa', status: 'Pending', time: 'Today • 4:30 PM', actions: true),
        _RequestCard(name: 'Sarah Jenkins', property: 'Burj Crown Panorama Penthouse', status: 'Confirmed', time: 'Thursday • 11:00 AM', actions: false),
        _RequestCard(name: 'Dr. Khalid Alzahrani', property: 'Marina Gate Waterfront Haven', status: 'Pending', time: 'Saturday • 6:00 PM', actions: true),
        _EndpointNotice(text: 'The supplied Laravel contract does not expose a dedicated agent viewing-request endpoint, so these controls are presentation-only until the backend endpoint is added.'),
      ],
    );
  }
}

class AgentMessagesPage extends StatefulWidget {
  const AgentMessagesPage({super.key});

  @override
  State<AgentMessagesPage> createState() => _AgentMessagesPageState();
}

class _AgentMessagesPageState extends State<AgentMessagesPage> {
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;

  static const _cacheKey = 'agent_messages_cache_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = await JsonCacheStorage.readList(_cacheKey);
    if (cached != null && mounted) {
      setState(() {
        _items = cached.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList(growable: false);
        _loading = false;
      });
    }

    try {
      final response = await ApiClient.get(
        '/api/profile/inquiries?page=1&per_page=12',
        authenticated: true,
      );
      final list = _findList(response);
      if (list != null) {
        final mapped = list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList(growable: false);
        await JsonCacheStorage.write(_cacheKey, mapped);
        if (mounted) setState(() => _items = mapped);
      }
    } catch (_) {
      // Cached messages remain visible when Render is sleeping/offline.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  dynamic _findList(dynamic value) {
    if (value is List) return value;
    if (value is! Map) return null;
    for (final key in const ['data', 'inquiries', 'items', 'results', 'records']) {
      final nested = _findList(value[key]);
      if (nested is List) return nested;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            _WebSectionHeader(title: 'Recent Messages', subtitle: 'Agent communication and property inquiries', icon: Icons.mail_outline_rounded),
            const SizedBox(height: 14),
            if (_items.isEmpty && !_loading)
              const _MessageCard(name: 'No live messages', text: 'The backend returned no inquiries for this account.', time: '—')
            else
              ..._items.take(8).map((item) => _MessageCard(
                    name: _text(item, ['name', 'user_name', 'sender_name', 'customer_name'], 'Property inquiry'),
                    text: _text(item, ['message', 'body', 'content', 'description'], 'New property inquiry'),
                    time: _text(item, ['created_at', 'updated_at'], 'Recently'),
                  )),
            if (_loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            const SizedBox(height: 8),
            const _EndpointNotice(text: 'Live data source: GET /api/profile/inquiries?page=1&per_page=12. The last successful response is cached locally for fast reopening.'),
          ],
        ),
      ),
    );
  }

  String _text(Map<String, dynamic> map, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }
}

class AgentAnalyticsPage extends StatefulWidget {
  const AgentAnalyticsPage({super.key});

  @override
  State<AgentAnalyticsPage> createState() => _AgentAnalyticsPageState();
}

class _AgentAnalyticsPageState extends State<AgentAnalyticsPage> {
  late final AgentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AgentController>() ? Get.find<AgentController>() : Get.put(AgentController(), permanent: true);
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Obx(() {
        final total = controller.pending.length + controller.approved.length + controller.rejected.length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            const _WebSectionHeader(title: 'Agent Analytics', subtitle: 'Performance summary from your live agent data', icon: Icons.bar_chart_rounded),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: MediaQuery.sizeOf(context).width >= 700 ? 1.75 : 1.45,
              children: [
                _MetricCard(label: 'My Properties', value: '$total', icon: Icons.home_work_outlined),
                _MetricCard(label: 'Approved', value: '${controller.approved.length}', icon: Icons.check_circle_outline_rounded),
                _MetricCard(label: 'Pending', value: '${controller.pending.length}', icon: Icons.pending_actions_rounded),
                _MetricCard(label: 'POIs', value: '${controller.pois.length}', icon: Icons.location_on_outlined),
              ],
            ),
            const SizedBox(height: 14),
            const _EndpointNotice(text: 'The Postman contract contains no dedicated agent analytics endpoint. These metrics are derived from GET /api/agent/properties and GET /api/agent/pois, not fabricated analytics values.'),
          ],
        );
      }),
    );
  }
}

class AgentSearchAlertsPage extends StatefulWidget {
  const AgentSearchAlertsPage({super.key});

  @override
  State<AgentSearchAlertsPage> createState() => _AgentSearchAlertsPageState();
}

class _AgentSearchAlertsPageState extends State<AgentSearchAlertsPage> {
  List<Map<String, dynamic>> _alerts = const [];
  bool _loading = true;

  static const _cacheKey = 'agent_search_alerts_cache_v1';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = await JsonCacheStorage.readList(_cacheKey);
    if (cached != null && mounted) {
      setState(() {
        _alerts = cached.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList(growable: false);
        _loading = false;
      });
    }
    try {
      final response = await ApiClient.get('/api/profile/search-alerts?page=1&per_page=12', authenticated: true);
      final list = _findList(response);
      if (list is List) {
        final mapped = list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList(growable: false);
        _alerts = mapped;
        await JsonCacheStorage.write(_cacheKey, mapped);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  dynamic _findList(dynamic value) {
    if (value is List) return value;
    if (value is! Map) return null;
    for (final key in const ['data', 'search_alerts', 'alerts', 'items', 'results']) {
      final nested = _findList(value[key]);
      if (nested is List) return nested;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Alerts'), actions: [IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded))]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            const _WebSectionHeader(title: 'Active Search Alerts', subtitle: 'Manage your real-time property notifications', icon: Icons.notifications_active_outlined),
            const SizedBox(height: 12),
            if (_alerts.isEmpty && !_loading)
              const _AlertCard(title: 'No saved alerts', subtitle: 'Create alerts from the search flow.'),
            ..._alerts.map((item) => _AlertCard(
                  title: _value(item, ['search_name', 'name', 'title'], 'Property Search Alert'),
                  subtitle: _value(item, ['description', 'query', 'summary'], 'Active search notification'),
                )),
            if (_loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            const SizedBox(height: 8),
            const _EndpointNotice(text: 'Live data source: GET /api/profile/search-alerts. The collection also exposes POST /api/search-alerts for creating a new alert; no delete endpoint is included, so the UI does not pretend to delete alerts.'),
          ],
        ),
      ),
    );
  }

  String _value(Map<String, dynamic> map, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return fallback;
  }
}

class AgentPreferencesPage extends StatefulWidget {
  const AgentPreferencesPage({super.key});

  @override
  State<AgentPreferencesPage> createState() => _AgentPreferencesPageState();
}

class _AgentPreferencesPageState extends State<AgentPreferencesPage> {
  final _area = TextEditingController(text: 'Dubai Marina');
  final _min = TextEditingController(text: '500000');
  final _max = TextEditingController(text: '3000000');
  bool _email = true;
  bool _browser = true;
  bool _saving = false;

  @override
  void dispose() {
    _area.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ApiClient.put(
        ApiEndpoints.profilePreferences,
        authenticated: true,
        body: {
          'preferred_area': _area.text.trim(),
          'property_types': [1, 2],
          'min_price': double.tryParse(_min.text) ?? 0,
          'max_price': double.tryParse(_max.text) ?? 0,
          'min_bedrooms': 1,
          'max_bedrooms': 4,
          'lifestyle_preferences': ['family_friendly', 'waterfront'],
          'email_notifications': _email,
          'browser_notifications': _browser,
        },
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Preferences')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        children: [
          const _WebSectionHeader(title: 'AI Search Preferences', subtitle: 'Customize your property search AI criteria', icon: Icons.tune_rounded),
          const SizedBox(height: 14),
          const Text('Preferred Property Types', style: TextStyle(fontWeight: FontWeight.w800)),
          CheckboxListTile(value: true, onChanged: null, title: const Text('Apartments'), contentPadding: EdgeInsets.zero),
          CheckboxListTile(value: true, onChanged: null, title: const Text('Villas'), contentPadding: EdgeInsets.zero),
          CheckboxListTile(value: false, onChanged: null, title: const Text('Penthouses'), contentPadding: EdgeInsets.zero),
          CheckboxListTile(value: false, onChanged: null, title: const Text('Townhouses'), contentPadding: EdgeInsets.zero),
          TextField(controller: _area, decoration: const InputDecoration(labelText: 'Preferred Area')),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(controller: _min, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Price (AED)'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _max, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Price (AED)')))]),
          const SizedBox(height: 10),
          SwitchListTile(value: _email, onChanged: (v) => setState(() => _email = v), title: const Text('Email notifications'), contentPadding: EdgeInsets.zero),
          SwitchListTile(value: _browser, onChanged: (v) => setState(() => _browser = v), title: const Text('Browser notifications'), contentPadding: EdgeInsets.zero),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_rounded), label: Text(_saving ? 'Saving…' : 'Save Preferences')),
          const SizedBox(height: 10),
          const _EndpointNotice(text: 'Live write endpoint: PUT /api/profile/preferences. The Postman collection does not provide a GET preferences endpoint, so the form uses the saved local defaults until the backend exposes a read endpoint.'),
        ],
      ),
    );
  }
}

class _StaticAgentSectionPage extends StatelessWidget {
  const _StaticAgentSectionPage({required this.title, required this.subtitle, required this.icon, required this.children});
  final String title, subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 36), children: [_WebSectionHeader(title: title, subtitle: subtitle, icon: icon), const SizedBox(height: 14), ...children]),
      );
}

class _WebSectionHeader extends StatelessWidget {
  const _WebSectionHeader({required this.title, required this.subtitle, required this.icon});
  final String title, subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: theme.colorScheme.outlineVariant)),
      child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: theme.colorScheme.primary)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]))]),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.labels});
  final List<String> labels;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: labels.map((e) => Chip(label: Text(e))).toList());
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.name, required this.property, required this.status, required this.time, required this.actions});
  final String name, property, status, time;
  final bool actions;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(child: Text(name.isEmpty ? 'A' : name.substring(0, 1))), const SizedBox(width: 10), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800))), Chip(label: Text(status))]), const SizedBox(height: 8), Text(property, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)), Text(time, style: theme.textTheme.bodySmall), if (actions) ...[const SizedBox(height: 10), Row(children: [Expanded(child: FilledButton(onPressed: null, child: const Text('Confirm Tour'))), const SizedBox(width: 8), Expanded(child: OutlinedButton(onPressed: null, child: const Text('Decline')))])]])));
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.name, required this.text, required this.time});
  final String name, text, time;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(time, style: Theme.of(context).textTheme.labelSmall),
          ),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const Spacer(), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), Text(label, style: Theme.of(context).textTheme.bodySmall)])));
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(subtitle),
            trailing: const Chip(label: Text('Active')),
          ),
        ),
      );
}

class _EndpointNotice extends StatelessWidget {
  const _EndpointNotice({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .35), borderRadius: BorderRadius.circular(14)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall))]));
}
