import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart'
    show AppPreferencesThemeMode;
import 'package:project_tweety/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';
import 'package:project_tweety/presentation/pages/home/home.page.dart';
import 'package:project_tweety/presentation/pages/settings/settings.page.dart';

import 'l10n/app_localizations.dart';

class NavigationItem {
  final Widget widget;
  final String label;
  final IconData icon;

  const NavigationItem({
    required this.widget,
    required this.label,
    required this.icon,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dartInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<AppPreferencesCubit>()..loadAppPreferences(),
        ),
      ],
      child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        builder: (context, state) {
          final appPreferences = state.effectiveAppPreferences;

          return MaterialApp(
            title: 'Project Tweety',
            theme: DesignSystemTheme.light(brand: DesignBrands.tweetyB2c),
            darkTheme: DesignSystemTheme.dark(brand: DesignBrands.tweetyB2c),
            themeMode: _themeMode(appPreferences.themeMode),
            locale: Locale(appPreferences.languageCode),
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
        },
      ),
    );
  }

  ThemeMode _themeMode(AppPreferencesThemeMode themeMode) {
    switch (themeMode) {
      case AppPreferencesThemeMode.system:
        return ThemeMode.system;
      case AppPreferencesThemeMode.light:
        return ThemeMode.light;
      case AppPreferencesThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}

class MyAppImpl extends StatefulWidget {
  const MyAppImpl({super.key});

  @override
  State<MyAppImpl> createState() => _MyAppImplState();
}

class _MyAppImplState extends State<MyAppImpl> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      NavigationItem(
        widget: const Home(),
        label: l10n.homeTab,
        icon: Icons.home,
      ),
      NavigationItem(
        widget: const Cards(),
        label: l10n.cardsTab,
        icon: Icons.grid_view_rounded,
      ),
      NavigationItem(
        widget: const Settings(),
        label: l10n.settingsTab,
        icon: Icons.settings,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: items.map((item) => item.widget).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
