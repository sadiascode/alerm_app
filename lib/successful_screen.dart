import 'package:alerm/login_screen.dart';
import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_screen.dart';

class SuccessfulScreen extends StatefulWidget {
  const SuccessfulScreen({super.key});

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
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

                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Text(
                    "Password Reset Successfully!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Color(0xffD7AAEC),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Text(
                    "Your password has been successfully reset.\nYou can now log in with your new password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Color(0xffD7AAEC),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),
                CustomButton(text: "Save Successfully", onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                })
              ]
          )
      ),
    );
  }
}