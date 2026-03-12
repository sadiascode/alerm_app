import '../models/alarm_model.dart';
import '../services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NotificationExamples {
  static final NotificationServices _notificationService = NotificationServices();


  static Future<void> scheduleAlarmExample() async {
    final alarm = AlarmModel(
      id: 'example_alarm_1',
      time: '07:30',
      activeDays: [1, 2, 3, 4, 5],
      isOn: true,
      createdAt: Timestamp.now(),
    );

    await _notificationService.scheduleAlarm(alarm);
    print('Alarm scheduled for ${alarm.time}');
  }


  static Future<void> cancelAlarmExample() async {
    const String alarmId = 'example_alarm_1';
    await _notificationService.cancelAlarm(alarmId);
    print('Alarm $alarmId cancelled');
  }


  static Future<void> cancelAllAlarmsExample() async {
    await _notificationService.cancelAllAlarms();
    print('All alarms cancelled');
  }


  static Future<void> checkPendingNotificationsExample() async {
    final pendingNotifications = await _notificationService.getPendingNotifications();
    print('Pending notifications: ${pendingNotifications.length}');
    for (final notification in pendingNotifications) {
      print('- ${notification.title} (ID: ${notification.id})');
    }
  }


  static Future<void> requestPermissionsExample() async {
    final bool granted = await _notificationService.requestPermissions();
    print('Permissions granted: $granted');
  }


  static Future<void> showTestNotificationExample() async {
    await _notificationService.showTestNotification();
    print('Test notification shown');
  }


  static Future<void> scheduleWeekendAlarmExample() async {
    final alarm = AlarmModel(
      id: 'weekend_alarm',
      time: '09:00',
      activeDays: [0, 6],
      isOn: true,
      createdAt: Timestamp.now(),
    );

    await _notificationService.scheduleAlarm(alarm);
    print('Weekend alarm scheduled for ${alarm.time}');
  }


  static Future<void> scheduleOneTimeAlarmExample() async {
    final alarm = AlarmModel(
      id: 'one_time_alarm',
      time: '14:30',
      activeDays: [],
      isOn: true,
      createdAt: Timestamp.now(),
    );

    await _notificationService.scheduleAlarm(alarm);
    print('One-time alarm scheduled for ${alarm.time}');
  }
}
