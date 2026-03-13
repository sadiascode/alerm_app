import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'app.dart';
import 'services/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications BEFORE runApp for real device reliability
  final localNotifications = NotificationServices();
  await localNotifications.initialize();

  runApp(const Alarm());

  // Initialize Firebase after app starts
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  });
}