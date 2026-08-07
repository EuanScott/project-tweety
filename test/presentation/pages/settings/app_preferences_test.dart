import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';

void main() {
  group('App preferences', () {
    useAppHarness();

    testWidgets('supports large text scaling without overflow on key screens', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester);

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

      await pumpApp(tester);

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
      await pumpApp(tester);

      await openAppPreferences(tester);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows the device theme setting when theme is overridden', (
      WidgetTester tester,
    ) async {
      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(
          const AppPreferences(themeMode: AppPreferencesThemeMode.light),
        ),
      );

      await pumpApp(
        tester,
        platformBrightness: Brightness.dark,
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      );

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Device setting: Dark'), findsOneWidget);
    });

    testWidgets('opens app preferences from a direct route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
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
  });
}
