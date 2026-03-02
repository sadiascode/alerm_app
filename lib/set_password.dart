import 'package:alerm/successful_screen.dart';
import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_field.dart';
import 'custom_screen.dart';
import 'login_screen.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key, });

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
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
                  Center(child: Text("Set New Password",style: TextStyle(fontSize: 24, color: Color(0xffD7AAEC),),)),

                  SizedBox(height: 13),
                  Center(
                    child: Text(
                      "Set your account password to secure your account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffD7AAEC),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  CustomField(
                    hintText: "New Password",
                    isPassword: true,
                  ),

                  SizedBox(height: 20),
                  CustomField(
                    hintText: "Retype New Password",
                    isPassword: true,
                  ),

                  SizedBox(height: 20),
                  CustomButton(
                    text: "Save",
                    onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SuccessfulScreen()),
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