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
      // Initialize timezone database
      tz.initializeTimeZones();
      
      // Set local location to device timezone
      final String timeZoneName = DateTime.now().timeZoneName;
      debugPrint('Device timezone: $timeZoneName');
      
      // Set timezone to Asia/Dhaka as specified
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
        debugPrint('Timezone set to Asia/Dhaka');
      } catch (e) {
        debugPrint('Failed to set Asia/Dhaka timezone: $e');
      }
    } catch (e) {
      debugPrint('Critical timezone initialization error: $e');
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
    } else if (Platform.isAndroid) {
      // Request Android permissions
      await requestPermissions();
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

      // Request notification permission
      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      
      // Request exact alarm permission (Android 12+)
      final bool? grantedExactAlarmPermission =
          await androidImplementation?.requestExactAlarmsPermission();
      
      debugPrint('Notification permission: $grantedNotificationPermission');
      debugPrint('Exact alarm permission: $grantedExactAlarmPermission');
      
      return (grantedNotificationPermission ?? false) && (grantedExactAlarmPermission ?? false);
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


    if (alarm.activeDays.isNotEmpty) {
      scheduledTime = _getNextActiveDayTime(
        scheduledTime,
        alarm.activeDays,
        now.weekday, // Use current weekday directly
      );
    } else {
      // For one-time alarms, only schedule if it's in the future
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
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

    // Normalize activeDays to ensure they're in range 1-7 (Monday=1, Sunday=7)
    final normalizedActiveDays = activeDays.map((day) {
      int normalized = day % 7;
      return normalized == 0 ? 7 : normalized; // Convert 0 to 7 (Sunday)
    }).toSet();
    
    final now = tz.TZDateTime.now(tz.local);
    
    // Check today first (convert weekday to 1-7 format)
    int todayIndex = now.weekday; // DateTime.weekday returns 1-7 (Monday=1, Sunday=7)
    if (normalizedActiveDays.contains(todayIndex) && scheduledTime.isAfter(now)) {
      debugPrint('Alarm scheduled for today: $scheduledTime');
      return scheduledTime;
    }
    
    // Check upcoming days in the next week
    for (int i = 1; i <= 7; i++) {
      int checkDayIndex = (todayIndex - 1 + i) % 7 + 1; // Convert to 1-7 format
      if (normalizedActiveDays.contains(checkDayIndex)) {
        // Create the target date by adding days to current date
        tz.TZDateTime targetDate = now.add(Duration(days: i));
        tz.TZDateTime result = tz.TZDateTime(
          tz.local,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
        
        // Ensure the result is in the future
        if (result.isAfter(now)) {
          debugPrint('Alarm scheduled for day $checkDayIndex in $i days: $result');
          return result;
        }
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
    // Use deterministic ID based on alarm ID hash for stable cancellation
    // This ensures the same alarm always gets the same notification ID
    final int baseId = alarmId.hashCode.abs();
    return (baseId % 100000) + 100000; // Keep IDs in predictable range
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

  /// Reschedule all active alarms from Firestore (called on app startup)
  Future<void> rescheduleAllActiveAlarms(List<AlarmModel> alarms) async {
    if (!_isInitialized) {
      await initialize();
    }

    debugPrint('Rescheduling ${alarms.length} active alarms...');
    
    // Cancel all existing alarm notifications first to avoid duplicates
    await cancelAllAlarms();
    
    // Schedule all active alarms
    int scheduledCount = 0;
    for (final alarm in alarms) {
      if (alarm.isOn) {
        try {
          await scheduleAlarm(alarm);
          scheduledCount++;
          debugPrint('Rescheduled alarm: ${alarm.id} at ${alarm.time}');
        } catch (e) {
          debugPrint('Failed to reschedule alarm ${alarm.id}: $e');
        }
      }
    }
    
    debugPrint('Successfully rescheduled $scheduledCount/$alarms.length alarms');
  }

  /// Get debug information about pending notifications
  Future<void> debugPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    final pending = await getPendingNotifications();
    debugPrint('=== Pending Notifications Debug ===');
    debugPrint('Total pending: ${pending.length}');
    
    for (final notification in pending) {
      debugPrint('ID: ${notification.id}, Title: ${notification.title}, Payload: ${notification.payload}');
    }
    debugPrint('=== End Debug ===');
  }
}
