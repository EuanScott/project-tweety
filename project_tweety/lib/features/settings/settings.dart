import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white24,
        child: const Center(
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}