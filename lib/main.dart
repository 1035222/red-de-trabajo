import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/repository_provider.dart';
import 'services/app_preferences.dart';
import 'services/push_notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PushNotificationService.initialize();
  await AppPreferences.instance.load();
  RepositoryProvider.useMock = false;
  runApp(const App());
}
