import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'app.dart';
import 'services/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // CRITICAL: Initialize local notifications FIRST for alarm reliability
  final localNotifications = NotificationServices();
  await localNotifications.initialize();

  runApp(const Alarm());
}
