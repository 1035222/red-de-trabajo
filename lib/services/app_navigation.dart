import 'package:flutter/material.dart';

import '../models/service.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/requests_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/service_detail_screen.dart';
import 'repository_provider.dart';

class AppNavigation {
  AppNavigation._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _homeIsReady = false;
  static Map<String, dynamic>? _pendingNotification;

  static void handleNotification(Map<String, dynamic> data) {
    if (!_homeIsReady) {
      _pendingNotification = Map<String, dynamic>.from(data);
      return;
    }
    _navigateToNotification(data);
  }

  static void homeReady() {
    _homeIsReady = true;
    final pendingNotification = _pendingNotification;
    if (pendingNotification == null) return;
    _pendingNotification = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNotification(pendingNotification);
    });
  }

  static void homeDisposed() {
    _homeIsReady = false;
  }

  static Future<void> _navigateToNotification(
    Map<String, dynamic> data,
  ) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingNotification = Map<String, dynamic>.from(data);
      return;
    }

    final type = data['type']?.toString();
    switch (type) {
      case 'chat_message':
      case 'chat_photo':
        final conversationId = data['conversationId']?.toString();
        if (conversationId == null || conversationId.isEmpty) return;
        await navigator.push<void>(
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversationId: conversationId),
          ),
        );
      case 'service_request':
        await navigator.push<void>(
          MaterialPageRoute(builder: (_) => const RequestsScreen()),
        );
      case 'review':
        final serviceId = data['serviceId']?.toString();
        if (serviceId == null || serviceId.isEmpty) {
          await navigator.push<void>(
            MaterialPageRoute(builder: (_) => const ReviewsScreen()),
          );
          return;
        }
        try {
          final Service? service = await RepositoryProvider.serviceRepository
              .getServiceById(serviceId);
          if (service == null) {
            await navigator.push<void>(
              MaterialPageRoute(builder: (_) => const ReviewsScreen()),
            );
            return;
          }
          await navigator.push<void>(
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: service),
            ),
          );
        } on Exception catch (error) {
          debugPrint('No se pudo abrir el servicio de la notificación: $error');
          await navigator.push<void>(
            MaterialPageRoute(builder: (_) => const ReviewsScreen()),
          );
        }
    }
  }
}
