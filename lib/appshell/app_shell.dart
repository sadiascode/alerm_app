import 'package:alerm/stopwatch/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../countdown/countdown.dart';
import '../services/notification_services.dart';
import 'custom_navbar.dart';
import '../home/home_screen.dart';
import '../services/alarm_service.dart';
import '../services/notification_services.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;
  final AlarmService _alarmService = AlarmService();
  final NotificationServices _notificationServices = NotificationServices();
  bool _hasRescheduledAlarms = false;

  final List<Widget> pages = [
    HomeScreen(),
    StopwatchScreen(),
    const Countdown(),
  ];

  @override
  void initState() {
    super.initState();
    _rescheduleAlarmsOnStartup();
  }

  Future<void> _rescheduleAlarmsOnStartup() async {
    if (_hasRescheduledAlarms) return;
    
    try {
      debugPrint('Rescheduling alarms on app startup...');
      
      // Get all alarms from Firestore
      final alarms = await _alarmService.getAlarms().first;
      
      // Reschedule all active alarms
      await _notificationServices.rescheduleAllActiveAlarms(alarms);
      
      _hasRescheduledAlarms = true;
      debugPrint('Alarm rescheduling completed on startup');
    } catch (e) {
      debugPrint('Error rescheduling alarms on startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A0E1E),

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomNavbar(
          items: const ["Alarm", "Stopwatch", "Countdown"],
          onChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}