import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:project_tweety/main.dart';

import 'support/in_memory_shared_preferences_async_platform.dart';

void main() {
  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsyncPlatform();
    await GetIt.I.reset();
    await configureCoreDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('renders app navigation tabs', (WidgetTester tester) async {
    await _pumpApp(tester);

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
    await tester.tap(find.text('App preferences'));
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
      Directionality.of(tester.element(find.text('העדפות האפליקציה'))),
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
    await tester.tap(find.text('App preferences'));
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
    await tester.tap(find.text('App preferences'));
    await tester.pumpAndSettle();

    await tester.tap(_languageDropdownFinder());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español').last);
    await tester.pumpAndSettle();

    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Preferencias de la aplicación'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(const MyApp());
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
