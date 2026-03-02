import 'package:flutter/material.dart';

class CustomScreen extends StatefulWidget {
  final String imagePath;
  final double imageHeight;
  final double imageWidth;
  final Widget child;

  const CustomScreen({
    super.key,
    required this.imagePath,
    required this.imageHeight,
    required this.imageWidth,
    required this.child,
  });

  @override
  State<CustomScreen> createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Container(color:Colors.black),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Center(
              child: Image.asset(
                widget.imagePath,
                height: widget.imageHeight,
                width: widget.imageWidth,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.67,
              widthFactor: 0.93,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}