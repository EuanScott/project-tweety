import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_tweety/presentation/pages/home/home.dart';
import 'package:project_tweety/presentation/pages/settings/settings.dart';

import 'core/themes/app_theme.dart';
import 'features/dynamic_form/application/dynamic_form.dart';
import 'l10n/app_localizations.dart';
import 'presentation/pages/other/other.dart';

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
      supportedLocales: const [Locale('en'), Locale('es')],
      home: const MyAppImpl(),
      // TODO: Setup navigatorObservers
    );
  }
}

class MyAppImpl extends StatefulWidget {
  const MyAppImpl({super.key});

  @override
  State<MyAppImpl> createState() => _MyAppImplState();
}

class _MyAppImplState extends State<MyAppImpl> {
  int _selectedIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List _screens = [
      {
        'widget': Home(l10n: l10n),
        'label': l10n.homeTab,
        'icon': const Icon(Icons.home),
      },
      // TODO: Make this a page that calls the Dynamic Form rather.
      {
        'widget': const DynamicForm(inputData: [], outputData: []),
        'label': l10n.dynamicFormTab,
        'icon': const Icon(Icons.power_input),
      },
      {
        'widget': const Other(),
        'label': l10n.otherTab,
        'icon': const Icon(Icons.other_houses),
      },
      {
        'widget': const Settings(),
        'label': l10n.settingsTab,
        'icon': const Icon(Icons.settings),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_screens[_selectedIndex]['label']),
        elevation: 2,
      ),
      body: _screens[_selectedIndex]['widget'],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectScreen,
          destinations: [
            for (final element in _screens)
              NavigationDestination(
                icon: element['icon'],
                label: element['label'] as String,
              ),
          ],
        ),
      ),
    );
  }
}
