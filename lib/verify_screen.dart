import 'package:alerm/set_password.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';

import 'custom_button.dart';
import 'custom_screen.dart';

class VerifyScreen extends StatefulWidget {


  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
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
                  SizedBox(height: 10),
                  Center(child: Text("Check your email",style: TextStyle(fontSize: 24,color: Color(0xffD7AAEC),),)),

                  SizedBox(height: 13),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "We sent a reset link to",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Color(0xffD7AAEC),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Please enter the 6 digit code.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Color(0xffD7AAEC),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 35),
                  PinCodeTextField(
                    length: 6,
                    obscureText: false,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    textStyle: const TextStyle(
                      color:  Color(0xffD7AAEC),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeColor: Color(0xffD7AAEC),
                        selectedColor: Color(0xffD7AAEC),
                        inactiveColor: Color(0xffD7AAEC)),
                    animationDuration: const Duration(milliseconds: 300),

                    appContext: context,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: (){},
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xffD7AAEC),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Container(
                          width: 83,
                          height: 1,
                          color: Color(0xffD7AAEC),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  CustomButton(
                    text: "Verify OTP",
                    onTap: (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SetPassword()),
                        );
                      },
                    isLoading: isLoading,
                  )
                ]
            )
        )
    );
  }
}