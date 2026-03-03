import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CountdownPage(),
    );
  }
}

class CountdownPage extends StatelessWidget {
  const CountdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Countdown(),
      ),
    );
  }
}

class Countdown extends StatefulWidget {
  const Countdown({Key? key}) : super(key: key);

  @override
  State<Countdown> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<Countdown> {
  Timer? _timer;

  final Duration initialTime = const Duration(hours: 1);
  Duration remaining = const Duration(hours: 1);

  late DateTime _endTime;
  bool isRunning = false;

  void _startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      _endTime = DateTime.now().add(remaining);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = _endTime.difference(DateTime.now());

      if (diff.isNegative) {
        _timer?.cancel();
        setState(() {
          remaining = Duration.zero;
          isRunning = false;
        });
      } else {
        setState(() {
          remaining = diff;
        });
      }
    });
  }

  void _pauseTimer() {
    if (!isRunning) return;

    _timer?.cancel();
    setState(() {
      remaining = _endTime.difference(DateTime.now());
      isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      remaining = initialTime;
      isRunning = false;
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Container(
          height: 260,
          width: 260,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xffD7AAEC),
              width: 6,
            ),
          ),
          child: Text(
            formatDuration(remaining),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 40),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    side: BorderSide(
                        color: Color(0xffD7AAEC),
                        width: 1
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20)
                    )
                ),
                child: const Text("Start", style: TextStyle(color: Color(0xffD7AAEC)),),
              ),

              ElevatedButton(
                onPressed: _pauseTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffD7AAEC)
                ),
                child: const Text("Pause"),
              ),

              ElevatedButton(
                onPressed: _resetTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  side: BorderSide(
                    color: Color(0xff777777),
                    width: 1,
                  ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20)
                    )
                ),
                child: const Text("Reset",style: TextStyle(color: Colors.grey),),
              ),
            ],
          ),
        )
      ],
    );
  }
}