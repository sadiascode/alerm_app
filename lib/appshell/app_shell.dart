import 'package:alerm/stopwatch/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../countdown/countdown.dart';
import 'custom_navbar.dart';
import '../home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeScreen(),
    StopwatchScreen(),
    const Countdown(),
  ];

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