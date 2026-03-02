import 'package:alerm/alerm_widget.dart';
import 'package:flutter/material.dart';

import 'alerm_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A0E1E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text("Upcoming alarm",
                    style: TextStyle(fontSize: 14, color: Colors.white54)),
              ),
              SizedBox(height: 10),
              Center(
                child: Text("6 hours 45 minutes",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              SizedBox(height: 10),
              Center(
                child: Text("Sunday, 21 Apr 09:16",
                    style: TextStyle(
                        fontSize: 10, color: Color(0xffD7AAEC))),
              ),
              SizedBox(height: 55),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: (){
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.85,
                          maxChildSize: 0.95,
                          minChildSize: 0.5,
                          builder: (_, controller) => const AlermPopup(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SizedBox(height: 40),
              AlermWidget(),
              SizedBox(height: 15),
              AlermWidget(),
              SizedBox(height: 15),
              AlermWidget(),
              SizedBox(height: 15),
              AlermWidget(),
              SizedBox(height: 15),
              AlermWidget(),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}