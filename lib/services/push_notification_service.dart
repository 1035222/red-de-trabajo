import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'app_navigation.dart';
import 'api_service.dart';

class PushNotificationService {
  PushNotificationService._();

  static const _enabledKey = 'push_notifications_enabled';
  static const _tokenKey = 'push_notification_token';
  static const _vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final StreamController<void> _notificationController =
      StreamController<void>.broadcast();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  static Stream<void> get notificationStream => _notificationController.stream;

  static Future<void> initialize() async {
    if (_initialized || !_supportsMessaging) return;
    _initialized = true;

    FirebaseMessaging.onMessage.listen((message) {
      _notificationController.add(null);
      final notification = message.notification;
      if (notification == null) return;
      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.translateText(notification.title ?? 'Red de Trabajo')}: '
            '${AppLocalizations.translateText(notification.body ?? '')}',
          ),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: () {
              messengerKey.currentState?.hideCurrentSnackBar();
              AppNavigation.handleNotification(message.data);
            },
          ),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        _notificationController.add(null);
        AppNavigation.handleNotification(message.data);
      },
    );

    _messaging.onTokenRefresh.listen((token) async {
      final preferences = await SharedPreferences.getInstance();
      if (!(preferences.getBool(_enabledKey) ?? false)) return;
      try {
        await _registerToken(token);
        await preferences.setString(_tokenKey, token);
      } on Exception catch (error) {
        debugPrint('No se pudo actualizar el token de notificaciones: $error');
      }
    });
  }

  static Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _notificationController.add(null);
      AppNavigation.handleNotification(message.data);
    }
  }

  static Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? false;
  }

  static Future<void> enable() async {
    if (!_supportsMessaging) {
      throw Exception(
        'Las notificaciones push no están disponibles en esta plataforma',
      );
    }
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      throw Exception(
        'Permite las notificaciones en la configuración del dispositivo',
      );
    }

    final token = await _messaging.getToken(
      vapidKey: kIsWeb && _vapidKey.isNotEmpty ? _vapidKey : null,
    );
    if (token == null || token.isEmpty) {
      throw Exception('Firebase no pudo generar el token de notificaciones');
    }

    await _registerToken(token);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
    await preferences.setBool(_enabledKey, true);
    await initialize();
  }

  static Future<void> disable() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      final response = await ApiService().patch('/notifications/tokens', {
        'token': token,
      });
      if (response.statusCode != 200) {
        throw Exception(
          'No se pudieron desactivar las notificaciones (${response.statusCode})',
        );
      }
    }

    await preferences.setBool(_enabledKey, false);
    await preferences.remove(_tokenKey);
    if (_supportsMessaging) await _messaging.deleteToken();
  }

  static Future<void> _registerToken(String token) async {
    final response = await ApiService().post('/notifications/tokens', {
      'token': token,
      'platform': _platformName,
    });
    if (response.statusCode != 200) {
      throw Exception(
        'No se pudieron activar las notificaciones (${response.statusCode}): ${response.body}',
      );
    }
  }

  static bool get _supportsMessaging =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static String get _platformName {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.macOS) return 'macos';
    return defaultTargetPlatform.name;
  }
}
