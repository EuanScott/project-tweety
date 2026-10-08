import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Cards page create action', () {
    useAppHarness();

    testWidgets('is a floating action button on Android', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.android,
      );

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.add),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(FloatingActionButton),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('Create card'), findsOneWidget);
    });

    testWidgets('stays in the navigation bar on iOS', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.iOS,
      );

      expect(
        find.descendant(
          of: find.byType(CupertinoSliverNavigationBar),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('lets the last card scroll clear of the floating action '
        'button', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.android,
      );

      await tester.fling(find.byType(ListView), const Offset(0, -5000), 5000);
      await tester.pumpAndSettle();

      final lastCard = find.ancestor(
        of: find.text('Card Title 10'),
        matching: find.byType(Card),
      );

      expect(
        tester.getRect(lastCard).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byType(FloatingActionButton)).top,
        ),
      );
    });

    testWidgets('keeps the floating action button over the list in a split '
        'layout', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.android,
      );

      final list = tester.getRect(find.byType(ListView));
      final button = tester.getRect(find.byType(FloatingActionButton));

      expect(button.right, lessThanOrEqualTo(list.right));
      expect(button.left, greaterThanOrEqualTo(list.left));
      expect(list.bottom - button.bottom, 16);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('stays in the navigation bar on iOS in a split layout', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.iOS,
      );

      expect(
        find.descendant(
          of: find.byType(CupertinoSliverNavigationBar),
          matching: find.byIcon(Icons.add),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('hides the floating action button while creating in a split '
        'layout', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsNewPath,
        platform: TargetPlatform.android,
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('opens the card editor from the floating action button', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.android,
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
