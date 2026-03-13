import 'package:alerm/widget/alerm_widget.dart';
import 'package:flutter/material.dart';
import '../../services/alarm_service.dart';
import '../../models/alarm_model.dart';

import '../widget/alerm_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AlarmService _alarmService = AlarmService();
  List<AlarmModel> _cachedAlarms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A0E1E),
      body: SafeArea(
        child: StreamBuilder<List<AlarmModel>>(
          stream: _alarmService.getAlarms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffD7AAEC)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final alarms = snapshot.data ?? [];
            _cachedAlarms = alarms; // Cache the alarms

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("Upcoming alarm",
                        style: TextStyle(fontSize: 14, color: Colors.white54)),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      alarms.isNotEmpty && alarms.first.isOn
                          ? _getNextAlarmTime(alarms.first)
                          : "No active alarms",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      alarms.isNotEmpty && alarms.first.isOn
                          ? _getNextAlarmDate(alarms.first)
                          : "Set an alarm to get started",
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xffD7AAEC)),
                    ),
                  ),
                  const SizedBox(height: 55),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        print('Clear All button pressed');
                        _showClearAllConfirmation(context);
                      },
                      child: const Text(
                        "Clear All",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => DraggableScrollableSheet(
                                initialChildSize: 0.85,
                                maxChildSize: 0.95,
                                minChildSize: 0.5,
                                builder: (_, controller) => const AlermPopup(),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                if (alarms.isEmpty)
            const Center(
              child: Text(
                "No alarms yet. Tap + to add one.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
            else
            ...alarms.map((alarm) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AlermWidget(alarm: alarm),
            )),
                ]
              )
            );
          },
        ),
      ),
    );
  }

  String _getNextAlarmTime(AlarmModel alarm) {
    return alarm.time;
  }

  String _getNextAlarmDate(AlarmModel alarm) {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(alarm.time.split(':')[0]),
      int.parse(alarm.time.split(':')[1]),
    );

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final activeDays = alarm.activeDays.map((day) => days[day]).toList();
    
    if (activeDays.isEmpty) return 'No active days';
    
    return activeDays.join(', ');
  }

  void _showClearAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff0A0E1E),
          title: const Text(
            'Clear All Alarms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete all alarms? This action cannot be undone.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xffD7AAEC),
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                print('Delete All confirmed');
                Navigator.of(context).pop(); // Close dialog
                
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleting all alarms...'),
                      backgroundColor: Color(0xffD7AAEC),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  print('Starting to delete all alarms...');
                  print('Current alarms count: ${_cachedAlarms.length}');
                  
                  // Delete all alarms
                  await _alarmService.deleteAllAlarms();
                  print('Delete operation completed');
                  
                  // Force refresh the UI
                  if (mounted) {
                    setState(() {
                      _cachedAlarms = [];
                    });
                  }
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All alarms deleted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error in delete operation: $e');
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete All',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}