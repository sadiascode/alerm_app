import 'package:alerm/services/auth_service.dart';
import 'package:alerm/home/home_screen.dart';
import 'package:alerm/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../widget/custom_button.dart';
import '../widget/custom_field.dart';
import '../widget/custom_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Handle signup
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  // Validate name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
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
      return 'Please enter a password';
    }
    return _authService.validatePassword(value);
  }

  // Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xffFFF0E6),
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
                  Center(child: Text("Welcome to Spark Time",style: TextStyle(fontSize: 24,color: Color(0xffD7AAEC),),)),
                  SizedBox(height: 15),

                  Center(child: Text("Sign up to get started",style: TextStyle(fontSize: 17,color: Color(0xffD7AAEC)),)),
                  SizedBox(height: 45),

                  CustomField(
                    hintText: "Full Name",
                    controller: nameController,
                    validator: _validateName,
                  ),
                  SizedBox(height: 18),

                  CustomField(
                    hintText: "Email",
                    controller: emailController,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 18),

                  CustomField(
                    hintText: "Password",
                    isPassword: true,
                    controller: passwordController,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 18),

                  CustomField(
                    hintText: "Confirm Password",
                    isPassword: true,
                    controller: confirmPasswordController,
                    validator: _validateConfirmPassword,
                  ),
                  SizedBox(height: 35),

                  CustomButton(
                    text: "Sign up",
                    onTap: _handleSignup,
                    isLoading: isLoading,
                  ),
              ]
          ),
        ),
      ),
      )
    );
  }
}