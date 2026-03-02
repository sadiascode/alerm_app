
import 'package:alerm/verify_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'custom_button.dart';
import 'custom_field.dart';
import 'custom_screen.dart';


class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color(0xffFFF0E6),
        body: CustomScreen(
            imagePath: 'assets/logo.jpeg',
            imageHeight: screenHeight * 0.319,
            imageWidth: screenWidth,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(child: Text("Forgot password?",style: TextStyle(fontSize: 24,color: Color(0xffD7AAEC)),)),

                  SizedBox(height: 13),
                  Center(
                    child: Text(
                      "Enter your email and we will send you a verification Code",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffD7AAEC),
                      ),
                    ),
                  ),

                  SizedBox(height: 60),
                  CustomField(
                    hintText: "Email",
                  ),

                  SizedBox(height: 20),
                  CustomButton(
                    text: "Send Code",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifyScreen()),
                        );
                    },
                  )

                ]
            )
        )
    );
  }
}