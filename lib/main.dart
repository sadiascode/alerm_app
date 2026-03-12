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

  final notificationService = NotificationService();
  await notificationService.initFCM();
  
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  runApp(const Alarm());
}

 Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Message : ${message.notification?.title}');
}