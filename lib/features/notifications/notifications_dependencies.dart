import 'data/datasources/notifications_remote_data_source.dart';
import 'data/models/notification_model.dart';

class NotificationsDependencies {
  NotificationsDependencies._();

  static final NotificationsRemoteDataSource remoteDataSource =
      const NotificationsRemoteDataSourceImpl();

  static Future<NotificationsResult> getNotifications() =>
      remoteDataSource.getNotifications();

  static Future<int> getUnreadCount() =>
      remoteDataSource.getUnreadCount();

  static Future<void> markAsRead(int id) =>
      remoteDataSource.markAsRead(id);

  static Future<void> markAllAsRead() =>
      remoteDataSource.markAllAsRead();

  static Future<void> delete(int id) =>
      remoteDataSource.delete(id);
}
