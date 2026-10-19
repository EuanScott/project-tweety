import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/platform/home_screen_shortcut.model.dart';
import 'package:project_tweety/core/platform/home_screen_shortcut.service.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../support/app_harness.dart';
import '../../support/fake_home_screen_shortcut_service.dart';

void main() {
  group('Home screen shortcuts', () {
    useAppHarness();

    Future<void> pick(WidgetTester tester, HomeScreenShortcut shortcut) async {
      (GetIt.I<HomeScreenShortcutService>() as FakeHomeScreenShortcutService)
          .pick(shortcut);
      await tester.pumpAndSettle();
    }

    testWidgets('New log opens the log entry editor', (tester) async {
      await pumpApp(tester);

      await pick(tester, HomeScreenShortcut.createLog);

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
      expect(find.text('New entry'), findsWidgets);
    });

    testWidgets('New log opens the editor once a signed-out person signs in', (
      tester,
    ) async {
      await pumpApp(tester, session: const Session.signedOut());

      await pick(tester, HomeScreenShortcut.createLog);
      await tester.tap(find.byType(AppGoogleSignInButton));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
    });
  });
}
