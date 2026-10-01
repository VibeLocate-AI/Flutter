import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../notifications_dependencies.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _loading = true;
  bool _working = false;
  String? _error;
  List<NotificationModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await NotificationsDependencies.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _markRead(NotificationModel item) async {
    if (item.isRead || _working) return;

    setState(() => _working = true);
    try {
      await NotificationsDependencies.markAsRead(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (value) => value.id == item.id
                  ? value.copyWith(isRead: true)
                  : value,
            )
            .toList(growable: false);
      });
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _markAllRead() async {
    if (_working || _items.every((item) => item.isRead)) return;

    setState(() => _working = true);
    try {
      await NotificationsDependencies.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map((item) => item.copyWith(isRead: true))
            .toList(growable: false);
      });
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete(NotificationModel item) async {
    try {
      await NotificationsDependencies.delete(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items
            .where((value) => value.id != item.id)
            .toList(growable: false);
      });
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _date(String? value) {
    if (value == null || value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final local = parsed.toLocal();
    final date = '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';

    return date;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('notifications')),
        actions: [
          TextButton(
            onPressed: _working ? null : _markAllRead,
            child: Text(localization.translate('mark_all_read')),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorView(theme, localization)
                : _items.isEmpty
                    ? _empty(theme, localization)
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _delete(item),
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              padding: const EdgeInsetsDirectional.only(end: 22),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: theme.colorScheme.onError,
                              ),
                            ),
                            child: _NotificationTile(
                              item: item,
                              date: _date(item.createdAt),
                              onTap: () => _markRead(item),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _empty(
    ThemeData theme,
    AppLocalization localization,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.24),
        Icon(
          Icons.notifications_none_rounded,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 14),
        Text(
          localization.translate('no_notifications'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _errorView(
    ThemeData theme,
    AppLocalization localization,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
        Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 14),
        Text(
          _error ?? '',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(localization.translate('try_again')),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.date,
    required this.onTap,
  });

  final NotificationModel item;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = item.isRead
        ? theme.colorScheme.surface
        : theme.colorScheme.primary.withValues(alpha: 0.06);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForType(item.type),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.message.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        item.message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsetsDirectional.only(start: 8, top: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'favorite':
      case 'favorites':
        return Icons.favorite_rounded;
      case 'property':
      case 'property_update':
        return Icons.home_work_rounded;
      case 'message':
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
