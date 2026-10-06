import 'package:material_ui/material_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/cards/card_details/card_details.page.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Cards back stack on an iOS phone', () {
    useAppHarness();

    final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

    Future<void> swipeBack(WidgetTester tester) async {
      await tester.dragFrom(const Offset(5, 450), const Offset(380, 0));
      await tester.pumpAndSettle();
    }

    void expectListOnTop() {
      expect(find.byType(CardDetailsPage), findsNothing);
      expect(find.text('New card'), findsNothing);
      expect(find.text('Card Title 1'), findsWidgets);
    }

    testWidgets('a card opened by deep link swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.byType(CardDetailsPage), findsOneWidget);

      await swipeBack(tester);

      expectListOnTop();
      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    }, variant: iOS);

    testWidgets('a newly saved card swipes back to the list', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Fresh title');
      await tester.enterText(find.byType(AppTextField).last, 'Fresh body');
      await tester.tap(find.text('Create card').last);
      await tester.pumpAndSettle();

      expect(find.byType(CardDetailsPage), findsOneWidget);

      await swipeBack(tester);

      expectListOnTop();
    }, variant: iOS);

    testWidgets('a card selected in split view swipes back after folding', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();
      await pumpApp(tester, surfaceSize: const Size(400, 900));

      expect(find.byType(CardDetailsPage), findsOneWidget);

      await swipeBack(tester);

      expectListOnTop();
    }, variant: iOS);

    testWidgets('an untouched new-card editor swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await swipeBack(tester);

      expectListOnTop();
      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    }, variant: iOS);

    testWidgets('a new-card editor with changes stays open on a swipe', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Unsaved');
      await tester.pump();
      await swipeBack(tester);

      expect(find.text('Unsaved'), findsOneWidget);
      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
    }, variant: iOS);

    testWidgets('an untouched card edit swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit card'));
      await tester.pumpAndSettle();
      await swipeBack(tester);

      expectListOnTop();
    }, variant: iOS);
  });
}
