
import 'package:alerm/login_screen.dart';
import 'package:alerm/signup_screen.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';

class Alarm extends StatelessWidget {
  const Alarm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "Alerm",
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}