import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'app.dart';
import 'notification/notification_service.dart';
import 'services/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler BEFORE app starts
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  // Initialize Firebase Messaging asynchronously without blocking app startup
  final notificationService = NotificationService();
  unawaited(notificationService.initFCM());

  runApp(const Alarm());
}

// Helper function to fire-and-forget async operations
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}

 @pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
  // Handle background message logic here
  // You can show local notifications or process data
}