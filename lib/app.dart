
import 'package:alerm/auth_wrapper.dart';
import 'package:flutter/material.dart';

class Alarm extends StatelessWidget {
  const Alarm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "Alerm",
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}