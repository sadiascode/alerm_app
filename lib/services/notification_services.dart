import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/alarm_model.dart';

class NotificationServices {
  static final NotificationServices _instance = NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;


    tz.initializeTimeZones();


    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');


    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );


    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    _isInitialized = true;
  }

  Future<void> _requestIOSPermissions() async {
    final bool? result = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (result == false) {
      debugPrint('iOS notification permissions denied');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      return grantedNotificationPermission ?? false;
    }
    return false;
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!_isInitialized) {
      await initialize();
    }


    await cancelAlarm(alarm.id!);


    final timeParts = alarm.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);


    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );


    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }


    if (alarm.activeDays.isNotEmpty) {

      int currentDayIndex = now.weekday % 7;
      scheduledTime = _getNextActiveDayTime(
        scheduledTime,
        alarm.activeDays,
        currentDayIndex,
      );
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Alarm notifications for scheduled alarms',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm_sound.aiff',
      categoryIdentifier: 'ALARM_CATEGORY',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _generateNotificationId(alarm.id!),
      'Alarm',
      'Your alarm is ringing!',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: alarm.activeDays.isNotEmpty
          ? DateTimeComponents.time
          : null,
    );

    debugPrint('Alarm scheduled: ${alarm.id} at $scheduledTime');
  }

  tz.TZDateTime _getNextActiveDayTime(
    tz.TZDateTime scheduledTime,
    List<int> activeDays,
    int currentDayIndex,
  ) {

    for (int i = 0; i < 7; i++) {
      int checkDayIndex = (currentDayIndex + i) % 7;
      if (activeDays.contains(checkDayIndex)) {
        if (i == 0 && scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {

          return scheduledTime;
        } else if (i > 0) {

          tz.TZDateTime nextTime = scheduledTime.add(Duration(days: i));
          return tz.TZDateTime(
            tz.local,
            nextTime.year,
            nextTime.month,
            nextTime.day,
            scheduledTime.hour,
            scheduledTime.minute,
          );
        }
      }
    }


    if (activeDays.isNotEmpty) {
      int firstActiveDay = activeDays.reduce((a, b) => a < b ? a : b);
      int daysToAdd = (7 - currentDayIndex + firstActiveDay) % 7;
      if (daysToAdd == 0) daysToAdd = 7;

      tz.TZDateTime nextTime = scheduledTime.add(Duration(days: daysToAdd));
      return tz.TZDateTime(
        tz.local,
        nextTime.year,
        nextTime.month,
        nextTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
    }

    return scheduledTime;
  }

  Future<void> cancelAlarm(String alarmId) async {
    if (!_isInitialized) {
      await initialize();
    }

    final int notificationId = _generateNotificationId(alarmId);
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    debugPrint('Alarm cancelled: $alarmId');
  }

  Future<void> cancelAllAlarms() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('All alarms cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  int _generateNotificationId(String alarmId) {

    return alarmId.hashCode.abs() % 100000;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification',
      platformChannelSpecifics,
    );
  }
}
