import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/home/home.page.dart';
import 'package:project_tweety/presentation/pages/route_error/route_error.page.dart';

import '../../support/app_harness.dart';

void main() {
  useAppHarness();

  Future<void> pumpMissingRoute(
    WidgetTester tester, {
    TargetPlatform platform = TargetPlatform.iOS,
    String location = '/missing',
  }) {
    return pumpApp(
      tester,
      initialLocation: location,
      platform: platform,
      disableAnimations: true,
    );
  }

  group('RouteErrorPage over Home', () {
    String location(WidgetTester tester) =>
        GoRouter.of(tester.element(find.byType(RouteErrorPage))).state.uri
            .toString();

    testWidgets('a broken deep link shows the page over Home, with no tabs', (
      tester,
    ) async {
      await pumpMissingRoute(tester, location: '/missing/deep/link');

      expect(find.byType(RouteErrorPage), findsOneWidget);
      expect(location(tester), AppRoutes.homeNotFoundPath);
      expect(find.text('Logs'), findsNothing);
    });

    testWidgets('swiping back on iOS reveals Home beneath', (tester) async {
      await pumpMissingRoute(tester);

      // A finger moves in steps. The first one only decides between the
      // swipe and the page's own vertical scrolling.
      final gesture = await tester.startGesture(const Offset(5, 400));
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(130, 0));
      await tester.pump();

      expect(find.byType(Home), findsOneWidget);
      expect(find.byType(RouteErrorPage), findsOneWidget);

      await gesture.moveBy(const Offset(150, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.homePath);
    });

    testWidgets('Go home pops back to Home', (tester) async {
      await pumpMissingRoute(tester);

      final context = tester.element(find.byType(RouteErrorPage));
      expect(GoRouter.of(context).canPop(), isTrue);

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.homePath);
    });

    testWidgets('Android system back returns to Home', (tester) async {
      await pumpMissingRoute(tester, platform: TargetPlatform.android);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.homePath);
    });

    testWidgets('signing in after a broken deep link still shows the page, '
        'and Go home lands on Home', (tester) async {
      await pumpApp(
        tester,
        session: const Session.signedOut(),
        initialLocation: '/missing',
        platform: TargetPlatform.iOS,
        disableAnimations: true,
      );
      await tester.tap(find.byType(AppGoogleSignInButton));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsOneWidget);

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.homePath);
    });
  });

  group('RouteErrorPage preview from Settings', () {
    testWidgets('shows the page over Settings, and Go home returns there', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initialLocation: '/settings',
        platform: TargetPlatform.iOS,
        disableAnimations: true,
      );

      await tester.tap(find.text('Preview page not found'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsOneWidget);

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.settingsPath);
    });
  });
}
