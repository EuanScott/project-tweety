import 'dart:async';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dartInit();

  runApp(const MyApp());
}

class const MyApp({
  final String? initialLocation,
  final AnalyticsFacade? analyticsFacade,
  final TargetPlatform? platform,
  final bool canAccessSettings = const bool.fromEnvironment(
    'CAN_ACCESS_SETTINGS',
    defaultValue: true,
  ),
  super.key,
}) extends StatefulWidget {
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

  //region Helpers

  ThemeMode _themeMode(AppPreferencesThemeMode themeMode) {
    switch (themeMode) {
      case .system:
        return .system;
      case .light:
        return .light;
      case .dark:
        return .dark;
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

  //endregion

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = GetIt.I<AppPreferencesCubit>();
            unawaited(cubit.loadAppPreferences());
            return cubit;
          },
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
}
