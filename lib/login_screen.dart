import 'package:alerm/app_shell.dart';
import 'package:alerm/signup_screen.dart';
import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_field.dart';
import 'custom_screen.dart';
import 'forget_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScreen(
        imagePath: 'assets/logo.jpeg',
        imageHeight: screenHeight * 0.319,
        imageWidth: screenWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Welcome to Spark Time",
                  style: TextStyle(fontSize: 24,color: Color(0xffD7AAEC)),
                ),
              ),
              const SizedBox(height: 15),
              CustomField(
                hintText: "Email",
                borderColor: const Color(0xffD7AAEC),

              ),
              const SizedBox(height: 17),
              CustomField(
                hintText: "Password",
                borderColor: const Color(0xffD7AAEC),
                isPassword: true,

              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text("Remember Me ", style: TextStyle(fontSize: 14,color: Color(0xffD7AAEC),)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgetScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 14, color: Color(0xffD7AAEC),),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: "Sign In",
                onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AppShell()),
                    );
                },
                isLoading: isLoading,
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xffD7AAEC),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffD7AAEC),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}