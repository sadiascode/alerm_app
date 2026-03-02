import 'package:alerm/home_screen.dart';
import 'package:alerm/login_screen.dart';
import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_field.dart';
import 'custom_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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

        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Welcome to Spark Time",style: TextStyle(fontSize: 24,color: Color(0xffD7AAEC),),)),
                SizedBox(height: 15),

                Center(child: Text("Sign up to get started",style: TextStyle(fontSize: 17,color: Color(0xffD7AAEC)),)),
                SizedBox(height: 45),

                CustomField(hintText: "Full Name", ),
                SizedBox(height: 18),

                CustomField(hintText: "Email ",),
                SizedBox(height: 18),

                CustomField(hintText: "Password",isPassword: true,),
                SizedBox(height: 35),

                CustomButton(text: "Sign up",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ]
          ),
        ),
      ),
    );
  }
}