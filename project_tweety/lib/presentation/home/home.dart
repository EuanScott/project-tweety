import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white24,
        child: const Center(
          child: Text(
            'Home',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}