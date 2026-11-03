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
      if (decoded is! List) {
        throw const FormatException(
          'La API devolvió un formato de notificaciones inválido',
        );
      }
      final List data = decoded;
      return data.map((json) => AppNotification.fromJson(json)).toList();
    }
    throw Exception(
      'Error al cargar notificaciones (${response.statusCode}): ${response.body}',
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _api.get('/notifications/unread-count');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['count'] is int) {
        return decoded['count'] as int;
      }
      throw const FormatException(
        'La API devolvió un contador de notificaciones inválido',
      );
    }
    throw Exception(
      'Error al cargar contador de notificaciones (${response.statusCode}): ${response.body}',
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final response = await _api.patch('/notifications/$notificationId', {
      'read': true,
    });
    if (response.statusCode != 200) {
      throw Exception(
        'Error al marcar notificación (${response.statusCode}): ${response.body}',
      );
    }
  }
}
