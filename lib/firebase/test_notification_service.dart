import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../examples/notification_examples.dart';

/// Test screen for notification service
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  String _status = 'Ready to test notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: const Color(0xFF252542),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final granted = await _notificationService.requestPermissions();
                  setState(() => _status = 'Permissions granted: $granted');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Request Permissions'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.showTestNotificationExample();
                  setState(() => _status = 'Test notification sent');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Show Test Notification'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.scheduleAlarmExample();
                  setState(() => _status = 'Alarm scheduled for 07:30 (Mon-Fri)');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Schedule Weekday Alarm'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.scheduleOneTimeAlarmExample();
                  setState(() => _status = 'One-time alarm scheduled for 14:30');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Schedule One-Time Alarm'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.cancelAlarmExample();
                  setState(() => _status = 'Alarm cancelled');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Cancel Alarm'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.checkPendingNotificationsExample();
                  setState(() => _status = 'Checked pending notifications');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Check Pending Notifications'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationExamples.cancelAllAlarmsExample();
                  setState(() => _status = 'All alarms cancelled');
                } catch (e) {
                  setState(() => _status = 'Error: $e');
                }
              },
              child: const Text('Cancel All Alarms'),
            ),
          ],
        ),
      ),
    );
  }
}
