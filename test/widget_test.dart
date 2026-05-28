import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:project_tweety/main.dart';

import 'support/in_memory_shared_preferences_async_platform.dart';

void main() {
  const systemTextSettingsChannel = MethodChannel(
    'project_tweety/system_text_settings',
  );

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsyncPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemTextSettingsChannel, (call) async {
          if (call.method == 'openTextSettings') {
            return true;
          }

          return null;
        });
    await GetIt.I.reset();
    await configureCoreDependencies();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemTextSettingsChannel, null);
    await GetIt.I.reset();
  });

  testWidgets('renders app navigation tabs', (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('redirects the root route to home', (WidgetTester tester) async {
    await _pumpApp(tester, initialLocation: AppRoutes.rootPath);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('switches to cards tab', (WidgetTester tester) async {
    GetIt.I
      ..unregister<AppPreferencesRepository>()
      ..registerLazySingleton<AppPreferencesRepository>(
        () => _FakeAppPreferencesRepository(
          const AppPreferences(languageCode: 'en'),
        ),
      );

    await _pumpApp(tester);

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsWidgets);
  });

  testWidgets('opens card details from the cards list on compact width', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, surfaceSize: const Size(400, 800));

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Card Title 1'));
    await tester.pumpAndSettle();

    expect(find.text('Card details'), findsOneWidget);
    expect(find.text('Card Title 1'), findsWidgets);
    expect(find.text('card-1'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('opens card details from a direct compact route', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      surfaceSize: const Size(400, 800),
      initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
    );

    expect(find.text('Card details'), findsOneWidget);
    expect(find.text('Card Title 1'), findsOneWidget);
    expect(find.text('card-1'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('shows cards list and details together on wide card route', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      surfaceSize: const Size(900, 800),
      initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Card Title 1'), findsWidgets);
    expect(find.text('card-1'), findsOneWidget);
  });

  testWidgets('scrolls selected card into view on wide direct card route', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      surfaceSize: const Size(900, 800),
      initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
    );

    final cardsList = tester.widget<ListView>(
      find.byWidgetPredicate(
        (widget) => widget is ListView && widget.controller != null,
      ),
    );

    expect(cardsList.controller!.offset, greaterThan(0));
    expect(find.text('Card Title 10'), findsNWidgets(2));
    expect(find.text('card-10'), findsOneWidget);
  });

  testWidgets('updates card details in place on wide card selection', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, surfaceSize: const Size(900, 800));

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    expect(find.text('Select a card'), findsOneWidget);

    await tester.tap(find.text('Card Title 1'));
    await tester.pumpAndSettle();

    expect(find.text('Card details'), findsNothing);
    expect(find.text('card-1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('card-1'), findsOneWidget);
  });

  testWidgets('active cards tab returns wide direct details route to root', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      surfaceSize: const Size(900, 800),
      initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
    );

    expect(find.text('card-1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('card-1'), findsNothing);
    expect(find.text('Select a card'), findsOneWidget);
  });

  testWidgets('tapping active cards tab returns card details to cards root', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      surfaceSize: const Size(400, 800),
      initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
    );

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Card details'), findsNothing);
    expect(find.text('card-1'), findsNothing);
    expect(find.text('Card Title 1'), findsOneWidget);
  });

  testWidgets('app follows the system locale when no language is stored', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('es');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    tester.platformDispatcher.localesTestValue = const <Locale>[Locale('es')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    GetIt.I
      ..unregister<AppPreferencesRepository>()
      ..registerLazySingleton<AppPreferencesRepository>(
        () => _FakeAppPreferencesRepository(const AppPreferences()),
      );

    await _pumpApp(tester);

    expect(find.text('Inicio'), findsWidgets);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, isNull);
  });

  testWidgets('selecting Hebrew updates locale and directionality', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAppPreferencesRepository(
      const AppPreferences(languageCode: 'en'),
    );

    GetIt.I
      ..unregister<AppPreferencesRepository>()
      ..registerLazySingleton<AppPreferencesRepository>(() => repository);

    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display and language'));
    await tester.pumpAndSettle();

    await tester.tap(_languageDropdownFinder());
    await tester.pumpAndSettle();
    await tester.tap(find.text('עברית').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('he'),
    );
    expect(
      Directionality.of(tester.element(find.text('תצוגה ושפה'))),
      TextDirection.rtl,
    );
    expect(repository.savedPreferences.last.languageCode, 'he');
  });

  testWidgets('selecting system default clears the stored language override', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAppPreferencesRepository(
      const AppPreferences(languageCode: 'en'),
    );

    GetIt.I
      ..unregister<AppPreferencesRepository>()
      ..registerLazySingleton<AppPreferencesRepository>(() => repository);

    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display and language'));
    await tester.pumpAndSettle();

    await tester.tap(_languageDropdownFinder());
    await tester.pumpAndSettle();
    await tester.tap(find.text('System default').last);
    await tester.pumpAndSettle();

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).locale, isNull);
    expect(repository.savedPreferences.last.languageCode, isNull);
  });

  testWidgets('switching language updates tab and settings labels', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAppPreferencesRepository(
      const AppPreferences(languageCode: 'en'),
    );

    GetIt.I
      ..unregister<AppPreferencesRepository>()
      ..registerLazySingleton<AppPreferencesRepository>(() => repository);

    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display and language'));
    await tester.pumpAndSettle();

    await tester.tap(_languageDropdownFinder());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español').last);
    await tester.pumpAndSettle();

    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Pantalla e idioma'), findsOneWidget);
  });

  testWidgets('supports large text scaling without overflow on key screens', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _pumpApp(tester);

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display and language'));
    await tester.pumpAndSettle();

    expect(find.text('Display and language'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens system text settings from app preferences', (
    WidgetTester tester,
  ) async {
    var methodCallCount = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemTextSettingsChannel, (call) async {
          if (call.method == 'openTextSettings') {
            methodCallCount += 1;
            return true;
          }

          return null;
        });

    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display and language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();

    expect(methodCallCount, 1);
  });

  testWidgets('keeps bottom navigation visible on app preferences', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await _openAppPreferences(tester);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('opens app preferences from a direct route', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.settingsAppPreferencesFullPath,
    );

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );

    expect(navigationBar.selectedIndex, 2);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('explains denied settings deep links', (
    WidgetTester tester,
  ) async {
    await _pumpApp(
      tester,
      initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      canAccessSettings: false,
    );

    expect(find.text('Theme'), findsNothing);
    expect(find.text('Access denied'), findsWidgets);
    expect(find.text('You do not have access to this page.'), findsOneWidget);
  });

  testWidgets('shows a navigation error page for unknown routes', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, initialLocation: '/missing');

    expect(find.text('Page not found'), findsWidgets);
    expect(
      find.text('The page you were looking for is not available.'),
      findsOneWidget,
    );
    expect(find.text('Go home'), findsOneWidget);
  });

  testWidgets('navigates home from the navigation error page', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, initialLocation: '/missing');

    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsNothing);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('tapping active settings tab returns nested route to root', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester);

    await _openAppPreferences(tester);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsNothing);
    expect(find.text('Display and language'), findsOneWidget);
  });

  testWidgets('tapping active cards tab scrolls cards list to the top', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, surfaceSize: const Size(400, 600));

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    final cardsList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.controller != null,
    );

    await tester.drag(cardsList, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsNothing);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsOneWidget);
  });

  testWidgets('tapping active cards rail item scrolls cards list to the top', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, surfaceSize: const Size(900, 800));

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    final cardsList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.controller != null,
    );

    await tester.drag(cardsList, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsNothing);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsOneWidget);
  });

  testWidgets('tapping active cards rail item scrolls selected cards list', (
    WidgetTester tester,
  ) async {
    await _pumpApp(tester, surfaceSize: const Size(900, 800));

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Card Title 1'));
    await tester.pumpAndSettle();

    final cardsList = find.byWidgetPredicate(
      (widget) => widget is ListView && widget.controller != null,
    );

    await tester.drag(cardsList, const Offset(0, -900));
    await tester.pumpAndSettle();

    final scrolledList = tester.widget<ListView>(cardsList);
    expect(scrolledList.controller!.offset, greaterThan(0));
    expect(find.text('card-1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsWidgets);
    expect(scrolledList.controller!.offset, 0);
    expect(find.text('card-1'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Size surfaceSize = const Size(400, 800),
  String? initialLocation,
  bool canAccessSettings = true,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MyApp(
      initialLocation: initialLocation,
      canAccessSettings: canAccessSettings,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openAppPreferences(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Display and language'));
  await tester.pumpAndSettle();
}

Finder _languageDropdownFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<String?>,
  );
}

class _FakeAppPreferencesRepository implements AppPreferencesRepository {
  _FakeAppPreferencesRepository(this._currentPreferences);

  AppPreferences _currentPreferences;
  final List<AppPreferences> savedPreferences = <AppPreferences>[];

  @override
  Future<AppPreferences> getAppPreferences() async {
    return _currentPreferences;
  }

  @override
  Future<void> saveAppPreferences(AppPreferences appPreferences) async {
    _currentPreferences = appPreferences;
    savedPreferences.add(appPreferences);
  }
}
