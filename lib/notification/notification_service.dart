import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  initFCM() async { await _firebaseMessaging.requestPermission();
  final fcmToken = await _firebaseMessaging.getToken();
  print("FCM Token : $fcmToken");
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Message : ${message.notification?.title}");
  }); FirebaseMessaging.onMessage.listen((RemoteMessage message)
  { print("Message : ${message.notification?.title}");
  }); } }