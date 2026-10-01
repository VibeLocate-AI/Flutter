import 'package:flutter/material.dart';

import '../../data/models/session_model.dart';
import '../../localization/security_strings.dart';
import '../../security_dependencies.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  bool _loading = true;
  String? _error;
  List<SessionModel> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final sessions = await SecurityDependencies.getSessions();
      if (!mounted) return;
      setState(() { _sessions = sessions; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _delete(SessionModel session) async {
    try {
      await SecurityDependencies.deleteSession(session.id);
      if (!mounted) return;
      setState(() => _sessions.removeWhere((item) => item.id == session.id));
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SecurityStrings.sessions)),
      body: RefreshIndicator(onRefresh: _load, child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return ListView(children: [SizedBox(height: 500, child: Center(child: CircularProgressIndicator()))]);
    if (_error != null) {
      return ListView(children: [SizedBox(height: 500, child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.error_outline_rounded, size: 50, color: Theme.of(context).colorScheme.error), const SizedBox(height: 14), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton(onPressed: _load, child: Text(SecurityStrings.retry))]))))]);
    }
    if (_sessions.isEmpty) return ListView(children: [SizedBox(height: 500, child: Center(child: Text(SecurityStrings.noSessions)))]);

    return LayoutBuilder(builder: (context, constraints) {
      final horizontal = constraints.maxWidth > 850 ? (constraints.maxWidth - 760) / 2 : 16.0;
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
        itemCount: _sessions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          final theme = Theme.of(context);
          final name = session.deviceModel.isEmpty ? session.deviceType : session.deviceModel;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, foregroundColor: theme.colorScheme.onPrimaryContainer, child: const Icon(Icons.devices_rounded)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text([
                if (session.deviceType.isNotEmpty) session.deviceType,
                if (session.osVersion.isNotEmpty) session.osVersion,
                '${SecurityStrings.activeTokens}: ${session.activeTokens}',
              ].join(' • ')),
              trailing: IconButton(tooltip: SecurityStrings.terminate, onPressed: () => _delete(session), icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error)),
            ),
          );
        },
      );
    });
  }
}
