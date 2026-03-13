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

  // CRITICAL: Initialize local notifications FIRST for alarm reliability
  final localNotifications = NotificationServices();
  await localNotifications.initialize();
  
  // Initialize Firebase Messaging asynchronously with timeout to prevent blocking
  final notificationService = NotificationService();
  unawaited(_initializeFCMWithTimeout(notificationService));

  // Set up background message handler for Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  runApp(const Alarm());
}

// Helper function to fire-and-forget async operations
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}

// Initialize Firebase Messaging with timeout to prevent blocking
Future<void> _initializeFCMWithTimeout(NotificationService notificationService) async {
  try {
    await notificationService.initFCM().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Firebase Messaging initialization timed out - continuing without FCM');
      },
    );
  } catch (e) {
    debugPrint('Firebase Messaging initialization error: $e');
    // Continue without blocking app startup
  }
}

 @pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
  // Handle background message logic here
  // You can show local notifications or process data
}