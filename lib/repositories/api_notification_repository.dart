import 'dart:convert';
import 'package:red_de_trabajo/services/api_service.dart';
import '../models/notification.dart';
import 'notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  final ApiService _api;

  ApiNotificationRepository(this._api);

  @override
  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/notifications');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => AppNotification.fromJson(json)).toList();
      }
      return [];
    }
    throw Exception('Error al obtener notificaciones');
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _api.put('/notifications/$notificationId/read', {});
  }
}
