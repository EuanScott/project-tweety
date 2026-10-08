import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/app_preferences/app_preferences.page.dart';

import '../../support/app_harness.dart';

void main() {
  group('Android navigation', () {
    useAppHarness();

    testWidgets('a pushed page resolves the predictive back transition', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.settingsPath);
      await tester.tap(find.text('Personalisation'));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AppPreferencesPage));

      expect(
        Theme.of(context).pageTransitionsTheme.builders[TargetPlatform.android],
        isA<PredictiveBackPageTransitionsBuilder>(),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    test('the app opts in to predictive back on Android 14 and later', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      final applicationTag = RegExp(
        '<application[^>]*>',
      ).firstMatch(manifest.replaceAll(RegExp('<!--.*?-->', dotAll: true), ''));

      expect(
        applicationTag?.group(0),
        contains('android:enableOnBackInvokedCallback="true"'),
      );
    });
  });
}
