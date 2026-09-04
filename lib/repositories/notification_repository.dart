import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> markAsRead(String notificationId);
}
