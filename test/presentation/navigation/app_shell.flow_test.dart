import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../support/app_harness.dart';
import '../../support/fake_app_preferences_repository.dart';

void main() {
  group('Navigation shell', () {
    useAppHarness();

    testWidgets('renders app navigation tabs', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Logs'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('redirects the root route to home', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.rootPath);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Logs'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('switches to logs tab', (WidgetTester tester) async {
      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(const AppPreferences(languageCode: 'en')),
      );

      await pumpApp(tester);

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('active logs tab returns wide direct details route to root', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(find.text('card-1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cabin));
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsNothing);
      expect(find.text('Select an entry'), findsOneWidget);
    });

    testWidgets(
      'tapping active logs tab returns log entry details to the Logs root',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(400, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.byIcon(Icons.cabin));
        await tester.pumpAndSettle();

        expect(find.text('Entry details'), findsNothing);
        expect(find.text('card-1'), findsNothing);
        expect(find.text('Card Title 1'), findsOneWidget);
      },
    );

    testWidgets('explains denied settings deep links', (
      WidgetTester tester,
    ) async {
      await pumpApp(
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
      await pumpApp(tester, initialLocation: '/missing');

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
      await pumpApp(tester, initialLocation: '/missing');

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.text('Page not found'), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('tapping active settings tab returns nested route to root', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await openAppPreferences(tester);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsNothing);
      expect(find.text('Personalisation'), findsOneWidget);
    });

    testWidgets('tapping active logs tab scrolls the Logs list to the top', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(400, 600));

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      final logsList = find.byWidgetPredicate(
        (widget) => widget is CustomScrollView && widget.controller != null,
      );

      await tester.drag(logsList, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsNothing);

      await tester.tap(find.byIcon(Icons.cabin));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets(
      'iOS Logs page uses large title scroll coordination without refresh action',
      (WidgetTester tester) async {
        await pumpApp(tester, platform: TargetPlatform.iOS);

        await tester.tap(find.text('Logs'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsNothing);

        final logsList = find.byType(CustomScrollView).first;
        final scrollView = tester.widget<CustomScrollView>(logsList);
        expect(scrollView.controller, isNotNull);
      },
    );

    testWidgets(
      'tapping active Logs rail item scrolls the Logs list to the top',
      (WidgetTester tester) async {
        await pumpApp(tester, surfaceSize: const Size(900, 800));

        await tester.tap(find.text('Logs'));
        await tester.pumpAndSettle();

        final logsList = find.byWidgetPredicate(
          (widget) => widget is CustomScrollView && widget.controller != null,
        );

        await tester.drag(logsList, const Offset(0, -900));
        await tester.pumpAndSettle();

        expect(find.text('Card Title 1'), findsNothing);

        await tester.tap(find.byIcon(Icons.cabin));
        await tester.pumpAndSettle();

        expect(find.text('Card Title 1'), findsOneWidget);
      },
    );

    testWidgets('tapping active Logs rail item resets a selected logs route', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(900, 800));

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      final logsList = find.byWidgetPredicate(
        (widget) => widget is CustomScrollView && widget.controller != null,
      );

      await tester.drag(logsList, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CustomScrollView>(logsList).controller!.offset,
        greaterThan(0),
      );
      expect(find.text('card-1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cabin));
      await tester.pumpAndSettle();

      final resetLogsList = tester.widget<CustomScrollView>(
        find.byWidgetPredicate(
          (widget) => widget is CustomScrollView && widget.controller != null,
        ),
      );

      expect(find.text('card-1'), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.logsPath);
      expect(
        resetLogsList.controller!.offset,
        greaterThan(0),
        reason:
            'clearing the selection keeps the list where the reader '
            'left it; a second tap on the active tab scrolls to the top',
      );

      await tester.tap(find.byIcon(Icons.cabin));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<CustomScrollView>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is CustomScrollView && widget.controller != null,
              ),
            )
            .controller!
            .offset,
        0,
      );
      expect(find.text('Card Title 1'), findsWidgets);
    });
  });
}
