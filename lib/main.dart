import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/analytics/analytics_facade.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart'
    show AppPreferencesThemeMode;
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:project_tweety/presentation/navigation/router.dart';
import 'package:project_tweety/presentation/pages/app_preferences/cubit/app_preferences.cubit.dart';

import 'l10n/app_localizations.dart';

/// TODO: docs
/// TODO: code cleanup
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dartInit();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    this.initialLocation,
    this.analyticsFacade,
    this.platform,
    this.canAccessSettings = const bool.fromEnvironment(
      'CAN_ACCESS_SETTINGS',
      defaultValue: true,
    ),
    super.key,
  });

  final String? initialLocation;
  final AnalyticsFacade? analyticsFacade;
  final TargetPlatform? platform;
  final bool canAccessSettings;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = createRouter(
    initialLocation: widget.initialLocation ?? AppRoutes.rootPath,
    analyticsFacade: widget.analyticsFacade ?? GetIt.I<AnalyticsFacade>(),
    canAccessSettings: widget.canAccessSettings,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<AppPreferencesCubit>()..loadAppPreferences(),
        ),
      ],
      child: BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
        buildWhen: (previous, current) {
          return previous.effectiveAppPreferences !=
              current.effectiveAppPreferences;
        },
        builder: (context, state) {
          final appPreferences = state.effectiveAppPreferences;

          return MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: _themeData(
              DesignSystemTheme.light(brand: DesignBrands.tweetyB2c),
            ),
            darkTheme: _themeData(
              DesignSystemTheme.dark(brand: DesignBrands.tweetyB2c),
            ),
            themeMode: _themeMode(appPreferences.themeMode),
            locale: _locale(appPreferences.languageCode),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            restorationScopeId: 'project_tweety_app',
            routerConfig: _router,
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

  ThemeData _themeData(ThemeData themeData) {
    final platform = widget.platform;
    if (platform == null) {
      return themeData;
    }

    return themeData.copyWith(platform: platform);
  }

  Locale? _locale(String? languageCode) {
    if (languageCode == null) {
      return null;
    }

    return Locale(languageCode);
  }
}
