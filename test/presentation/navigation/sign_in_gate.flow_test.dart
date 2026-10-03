import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/sign_in/sign_in.page.dart';

import '../../support/app_harness.dart';
import '../../support/fake_auth_repository.dart';

void main() {
  group('Launch gate', () {
    useAppHarness();

    Future<void> signIn(WidgetTester tester) async {
      await tester.tap(find.byType(AppGoogleSignInButton));
      await tester.pumpAndSettle();
    }

    testWidgets('launching signed out shows sign-in without the tab shell', (
      tester,
    ) async {
      await pumpApp(tester, session: const Session.signedOut());

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.signInPath);
    });

    testWidgets('a deep link while signed out shows sign-in, and signing in '
        'lands on that location', (tester) async {
      await pumpApp(
        tester,
        session: const Session.signedOut(),
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      );

      expect(find.byType(SignInPage), findsOneWidget);

      await signIn(tester);

      expect(find.byType(SignInPage), findsNothing);
      expect(
        currentRoutePath(tester),
        AppRoutes.settingsAppPreferencesFullPath,
      );
    });

    testWidgets('signing in from the root lands on Home', (tester) async {
      await pumpApp(tester, session: const Session.signedOut());

      await signIn(tester);

      expect(currentRoutePath(tester), AppRoutes.homePath);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('signing out mid-session returns to sign-in', (tester) async {
      final repository = FakeAuthRepository();
      replaceAuthRepository(repository);
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);
      expect(find.byType(SignInPage), findsNothing);

      repository.emit(const Session.signedOut());
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('a signed-in person who opens sign-in goes Home', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.signInPath);

      expect(find.byType(SignInPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.homePath);
    });
  });
}
