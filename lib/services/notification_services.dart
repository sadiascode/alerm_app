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

    try {
      tz.initializeTimeZones();
      debugPrint('Timezones initialized successfully');
    } catch (e) {
      debugPrint('Error initializing timezones: $e');
      rethrow;
    }


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
      channelShowBadge: true,
      enableLights: true,
      autoCancel: false, // Don't auto-cancel alarm notifications
      ongoing: true, // Make it ongoing until dismissed
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
      payload: _createPayload(alarm),
    );

    debugPrint('Alarm scheduled: ${alarm.id} at $scheduledTime');
  }

  tz.TZDateTime _getNextActiveDayTime(
    tz.TZDateTime scheduledTime,
    List<int> activeDays,
    int currentDayIndex,
  ) {
    debugPrint('Finding next active day. Current day index: $currentDayIndex, Active days: $activeDays');

    // Normalize activeDays to ensure they're in range 0-6 (Monday=0, Sunday=6)
    final normalizedActiveDays = activeDays.map((day) => day % 7).toList();
    
    final now = tz.TZDateTime.now(tz.local);
    
    // Check today first
    if (normalizedActiveDays.contains(currentDayIndex) && scheduledTime.isAfter(now)) {
      debugPrint('Alarm scheduled for today: $scheduledTime');
      return scheduledTime;
    }
    
    // Check upcoming days in the next week
    for (int i = 1; i <= 7; i++) {
      int checkDayIndex = (currentDayIndex + i) % 7;
      if (normalizedActiveDays.contains(checkDayIndex)) {
        tz.TZDateTime nextTime = scheduledTime.add(Duration(days: i));
        tz.TZDateTime result = tz.TZDateTime(
          tz.local,
          nextTime.year,
          nextTime.month,
          nextTime.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
        debugPrint('Alarm scheduled for day $checkDayIndex in $i days: $result');
        return result;
      }
    }

    // Fallback (should never reach here if activeDays is not empty)
    debugPrint('No active day found, using scheduled time as fallback');
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
    
    if (response.payload != null) {
      final alarmData = _parsePayload(response.payload!);
      _handleAlarmAction(alarmData);
    }
  }

  String _createPayload(AlarmModel alarm) {
    return 'alarm_id:${alarm.id}|time:${alarm.time}|days:${alarm.activeDays.join(',')}';
  }

  Map<String, String> _parsePayload(String payload) {
    final Map<String, String> data = {};
    final parts = payload.split('|');
    
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }
    
    return data;
  }

  void _handleAlarmAction(Map<String, String> alarmData) {
    final alarmId = alarmData['alarm_id'];
    if (alarmId != null) {
      debugPrint('Handling alarm action for: $alarmId');
      // Navigate to alarm screen or perform alarm-specific action
      // You can use a navigation service or callback to handle this
    }
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
