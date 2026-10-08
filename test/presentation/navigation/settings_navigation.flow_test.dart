import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/app_preferences/app_preferences.page.dart';
import 'package:project_tweety/presentation/pages/settings/settings.page.dart';

import '../../support/app_harness.dart';

void main() {
  group('Settings navigation on iOS', () {
    useAppHarness();

    testWidgets('app preferences slides in and swipes back to settings', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.settingsPath);

      await tester.tap(find.text('Personalisation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final route = ModalRoute.of(
        tester.element(find.byType(AppPreferencesPage)),
      )!;
      expect(route, isA<CupertinoRouteTransitionMixin<void>>());
      expect(route.animation!.isAnimating, isTrue);

      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(5, 400), const Offset(380, 0));
      await tester.pumpAndSettle();

      expect(find.byType(AppPreferencesPage), findsNothing);
      expect(find.byType(Settings), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('restores app preferences after the app restarts', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.settingsPath);
      await tester.tap(find.text('Personalisation'));
      await tester.pumpAndSettle();

      await tester.restartAndRestore();

      expect(find.byType(AppPreferencesPage), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });
}
