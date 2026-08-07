import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';

import '../support/app_harness.dart';
import '../support/fake_app_preferences_repository.dart';

void main() {
  group('Localization and directionality', () {
    useAppHarness();

    testWidgets('app follows the system locale when no language is stored', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('es');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      tester.platformDispatcher.localesTestValue = const <Locale>[Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(const AppPreferences()),
      );

      await pumpApp(tester);

      expect(find.text('Inicio'), findsWidgets);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        isNull,
      );
    });

    testWidgets('selecting Hebrew updates locale and directionality', (
      WidgetTester tester,
    ) async {
      final repository = FakeAppPreferencesRepository(
        const AppPreferences(languageCode: 'en'),
      );

      replaceAppPreferencesRepository(repository);

      await pumpApp(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();

      await tester.tap(languageDropdownFinder());
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

    testWidgets(
      'selecting system default clears the stored language override',
      (WidgetTester tester) async {
        final repository = FakeAppPreferencesRepository(
          const AppPreferences(languageCode: 'en'),
        );

        replaceAppPreferencesRepository(repository);

        await pumpApp(tester);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Display and language'));
        await tester.pumpAndSettle();

        await tester.tap(languageDropdownFinder());
        await tester.pumpAndSettle();
        await tester.tap(find.text('System default').last);
        await tester.pumpAndSettle();

        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
          isNull,
        );
        expect(repository.savedPreferences.last.languageCode, isNull);
      },
    );

    testWidgets('switching language updates tab and settings labels', (
      WidgetTester tester,
    ) async {
      final repository = FakeAppPreferencesRepository(
        const AppPreferences(languageCode: 'en'),
      );

      replaceAppPreferencesRepository(repository);

      await pumpApp(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();

      await tester.tap(languageDropdownFinder());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español').last);
      await tester.pumpAndSettle();

      expect(find.text('Tema'), findsOneWidget);
      expect(find.text('Pantalla e idioma'), findsOneWidget);
    });
  });
}
