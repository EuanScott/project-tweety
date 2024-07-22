import 'package:flutter/material.dart';

import './other.dart';
import 'features/home/home.dart';
import 'features/library/application/library.dart';
import 'features/settings/settings.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

  final List _screens = [
    {
      'widget': const Home(),
      'label': 'Home',
      'icon': const Icon(Icons.home),
    },
    {
      'widget': const Library(formData: [],formResponse: []),
      'label': 'Library',
      'icon': const Icon(Icons.library_books),
    },
    {
      'widget': const Other(),
      'label': 'Other',
      'icon': const Icon(Icons.other_houses),
    },
    {
      'widget': const Settings(),
      'label': 'Settings',
      'icon': const Icon(Icons.settings),
    }
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex]['widget'],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedIconTheme: const IconThemeData(color: Colors.yellow, size: 30),
            selectedItemColor: Colors.yellow,
            onTap: _selectScreen,
            items: [
              for (var element in _screens)
                BottomNavigationBarItem(
                  icon: element['icon'],
                  label: element['label'],
                )
            ]),
      ),
    );
  }
}
