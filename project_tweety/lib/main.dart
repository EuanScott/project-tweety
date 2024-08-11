import 'package:flutter/material.dart';

import './other.dart';
import 'features/dynamic_form/application/dynamic_form.dart';
import 'features/home/home.dart';
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
      'widget': const DynamicForm(inputData: [], outputData: []),
      'label': 'Dynamic Form',
      'icon': const Icon(Icons.power_input),
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
            selectedIconTheme:
                const IconThemeData(color: Color(0XFF8cd2d5), size: 30),
            selectedItemColor: const Color(0XFF8cd2d5),
            unselectedIconTheme:
                const IconThemeData(color: Colors.grey, size: 25),
            unselectedItemColor: Colors.grey,
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
