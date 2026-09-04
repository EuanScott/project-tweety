import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('CardsDraftDiscardGuard', () {
    useAppHarness();

    testWidgets(
      'shows discard confirmation dialog when navigating away from dirty create draft',
      (WidgetTester tester) async {
        await pumpApp(tester, initialLocation: AppRoutes.cardsNewPath);

        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Discard changes?'), findsOneWidget);
      },
    );

    testWidgets(
      'shows discard confirmation dialog when navigating away from dirty edit draft',
      (WidgetTester tester) async {
        replaceCardsRepository(FakeCardsRepository());

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Edit card'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(AppTextField).first, 'Updated title');
        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Discard changes?'), findsOneWidget);
      },
    );

    testWidgets(
      'allows navigation without dialog when draft is clean',
      (WidgetTester tester) async {
        await pumpApp(tester, initialLocation: AppRoutes.cardsNewPath);

        // Don't enter any text - draft is clean
        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(currentRoutePath(tester), AppRoutes.cardsPath);
      },
    );
  });
}
