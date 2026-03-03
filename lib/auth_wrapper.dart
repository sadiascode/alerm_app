import 'package:alerm/auth_service.dart';
import 'package:alerm/login_screen.dart';
import 'package:alerm/app_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffD7AAEC)),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const AppShell();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
