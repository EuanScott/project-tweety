import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/pages/home/home.dart';
import 'package:project_tweety/presentation/pages/settings/settings.dart';

import 'core/themes/app_theme.dart';
import 'core/themes/color_theme.dart';
import 'features/dynamic_form/application/dynamic_form.dart';
import 'l10n/app_localizations.dart';
import 'presentation/pages/other/other.dart';


import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Project Tweety',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        home: const MyHomePage()
        // TODO: Setup navigatorObservers
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List _screens = [
      {
        'widget': const Home(),
        'label': localizations.homeTab,
        'icon': const Icon(Icons.home),
      },
      {
        'widget': const DynamicForm(inputData: [], outputData: []),
        'label': localizations.dynamicFormTab,
        'icon': const Icon(Icons.power_input),
      },
      {
        'widget': const Other(),
        'label': localizations.otherTab,
        'icon': const Icon(Icons.other_houses),
      },
      {
        'widget': const Settings(),
        'label': localizations.settingsTab,
        'icon': const Icon(Icons.settings),
      }
    ];

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
                const IconThemeData(color: ColorTheme.primary, size: 30),
            selectedItemColor: ColorTheme.primary,
            unselectedIconTheme:
                const IconThemeData(color: ColorTheme.textPrimary, size: 25),
            unselectedItemColor: ColorTheme.textPrimary,
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
