import 'dart:convert' as convert;

import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {

  @override
  void initState() {
    super.initState();
    // TODO: Call the services endpoints here?
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white24,
        child: const Center(
          child: Text(
            'Library',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}