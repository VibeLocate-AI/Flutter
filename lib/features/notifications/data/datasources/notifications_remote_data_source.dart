import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsResult> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<void> delete(int id);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl();

  @override
  Future<NotificationsResult> getNotifications() async {
    final response = await ApiClient.get(
      ApiEndpoints.notifications,
      authenticated: true,
    );

    final items = _parseNotifications(response);
    final unread = _parseUnreadCount(response, items);

    return NotificationsResult(
      items: List<NotificationModel>.unmodifiable(items),
      unreadCount: unread,
    );
  }

  List<NotificationModel> _parseNotifications(
    Map<String, dynamic> response,
  ) {
    final candidates = <dynamic>[
      response['notifications'],
      response['items'],
      response['data'],
    ];

    for (final candidate in candidates) {
      final list = _extractList(candidate);
      if (list != null) {
        return list
            .map(_toJsonMap)
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
    }

    return const [];
  }

  List<dynamic>? _extractList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      final map = _toJsonMap(value);
      if (map == null) return null;

      for (final key in const [
        'notifications',
        'items',
        'data',
        'results',
      ]) {
        final nested = map[key];
        if (nested is List) return nested;
      }
    }

    return null;
  }

  Map<String, dynamic>? _toJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  int _parseUnreadCount(
    Map<String, dynamic> response,
    List<NotificationModel> items,
  ) {
    for (final source in <dynamic>[
      response['unread_count'],
      _toJsonMap(response['data'])?['unread_count'],
      _toJsonMap(response['meta'])?['unread_count'],
    ]) {
      final value = int.tryParse(source?.toString() ?? '');
      if (value != null) return value;
    }

    return items.where((item) => !item.isRead).length;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await ApiClient.get(
      ApiEndpoints.notificationsUnreadCount,
      authenticated: true,
    );

    return int.tryParse(
          response['unread_count']?.toString() ?? '',
        ) ??
        int.tryParse(
          _toJsonMap(response['data'])?['unread_count']?.toString() ?? '',
        ) ??
        0;
  }

  @override
  Future<void> markAsRead(int id) async {
    await ApiClient.put(
      ApiEndpoints.notificationRead(id),
      authenticated: true,
    );
  }

  @override
  Future<void> markAllAsRead() async {
    await ApiClient.put(
      ApiEndpoints.notificationsReadAll,
      authenticated: true,
    );
  }

  @override
  Future<void> delete(int id) async {
    await ApiClient.delete(
      ApiEndpoints.notificationDelete(id),
      authenticated: true,
    );
  }
}
