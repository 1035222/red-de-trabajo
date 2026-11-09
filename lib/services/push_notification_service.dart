import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'app_navigation.dart';
import 'api_service.dart';

class PushNotificationService {
  PushNotificationService._();

  static const _enabledKey = 'push_notifications_enabled';
  static const _tokenKey = 'push_notification_token';
  static const _channelId = 'red_de_trabajo_notifications';
  static const _channelName = 'Red de Trabajo';
  static const _vapidKey = String.fromEnvironment('FCM_VAPID_KEY');
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final StreamController<void> _notificationController =
      StreamController<void>.broadcast();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Stream<void> get notificationStream => _notificationController.stream;

  static Future<void> initialize() async {
    if (_initialized || !_supportsMessaging) return;
    _initialized = true;

    await _initializeLocalNotifications();
    FirebaseMessaging.onMessage.listen((message) async {
      if (!await isEnabled()) return;
      _notificationController.add(null);
      final notification = message.notification;
      if (notification == null) return;
      if (kIsWeb) {
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
        return;
      }
      await _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      if (!await isEnabled()) return;
      _notificationController.add(null);
      AppNavigation.handleNotification(message.data);
    });

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

  static Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return;

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: 'Mensajes y actividad de Red de Trabajo',
              importance: Importance.max,
              playSound: true,
            ),
          );
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
        title: AppLocalizations.translateText(
          message.notification?.title ?? 'Red de Trabajo',
        ),
        body: AppLocalizations.translateText(message.notification?.body ?? ''),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Mensajes y actividad de Red de Trabajo',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } on Exception catch (error) {
      debugPrint('No se pudo mostrar la notificación recibida: $error');
    }
  }

  static void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        AppNavigation.handleNotification(data);
      } else {
        debugPrint('La notificación local no contiene datos de navegación');
      }
    } on FormatException catch (error) {
      debugPrint('Los datos de la notificación local no son válidos: $error');
    }
  }

  static Future<void> handleInitialMessage() async {
    if (!await isEnabled()) return;
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _notificationController.add(null);
      AppNavigation.handleNotification(message.data);
      return;
    }

    if (!kIsWeb) {
      final launchDetails = await _localNotifications
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _handleLocalNotificationTap(
          launchDetails?.notificationResponse?.payload,
        );
      }
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
    _notificationController.add(null);
  }

  static Future<void> disable() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    await preferences.setBool(_enabledKey, false);

    Exception? failure;
    if (token != null && token.isNotEmpty) {
      try {
        final response = await ApiService().patch('/notifications/tokens', {
          'token': token,
        });
        if (!_isSuccessful(response.statusCode)) {
          failure = Exception(
            'No se pudieron desactivar las notificaciones (${response.statusCode}): ${response.body}',
          );
        }
      } on Exception catch (error) {
        failure = Exception(
          'No se pudo desregistrar el token de notificaciones: $error',
        );
      }
    }

    await preferences.remove(_tokenKey);
    _notificationController.add(null);
    if (_supportsMessaging) {
      try {
        await _messaging.deleteToken();
      } on Exception catch (error) {
        failure ??= Exception(
          'No se pudo eliminar el token local de notificaciones: $error',
        );
      }
    }
    if (failure != null) throw failure;
  }

  static Future<void> _registerToken(String token) async {
    final response = await ApiService().post('/notifications/tokens', {
      'token': token,
      'platform': _platformName,
    });
    if (!_isSuccessful(response.statusCode)) {
      throw Exception(
        'No se pudieron activar las notificaciones (${response.statusCode}): ${response.body}',
      );
    }
  }

  static bool _isSuccessful(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

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
