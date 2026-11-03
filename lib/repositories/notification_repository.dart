import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
}
