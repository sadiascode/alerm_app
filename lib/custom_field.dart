import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String? hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final Color textColor;
  final Color borderColor;
  final String? Function(String?)? validator;

  const CustomField({
    super.key,
    this.hintText,
    this.isPassword = false,
    this.controller,
    this.textColor = const Color(0xffD7AAEC),
    this.borderColor = const Color(0xffD7AAEC),
    this.validator,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      validator: widget.validator,
      style: TextStyle(
        color: widget.textColor,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Color(0xffD7AAEC),
          fontSize: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: BorderSide(
            color: widget.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: BorderSide(
            color: widget.borderColor,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Color(0xffD7AAEC),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}