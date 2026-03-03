import 'package:alerm/appshell/app_shell.dart';
import 'package:alerm/services/auth_service.dart';
import 'package:alerm/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import '../widget/custom_button.dart';
import '../widget/custom_field.dart';
import '../widget/custom_screen.dart';

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
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Handle login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_authService.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: _formKey,
        child: CustomScreen(
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
                  controller: emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 17),
                CustomField(
                  hintText: "Password",
                  borderColor: const Color(0xffD7AAEC),
                  isPassword: true,
                  controller: passwordController,
                  validator: _validatePassword,
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

              const SizedBox(height: 15),
              CustomButton(
                text: "Sign In",
                onTap: _handleLogin,
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
        ]
      )
     )
   )
  )
);
  }
}