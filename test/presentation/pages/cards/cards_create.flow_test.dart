import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('Creating a Card', () {
    useAppHarness();

    testWidgets('turns the editor into the new Card in place when the region '
        'shows one pane', (tester) async {
      replaceCardsRepository(FakeCardsRepository());
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.tap(find.byTooltip('Create card'));
      await tester.pumpAndSettle();
      final editorRoute = ModalRoute.of(
        tester.element(find.byType(AppTextField).first),
      );

      await _fillAndCreate(tester);

      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}created-card',
      );
      expect(
        ModalRoute.of(tester.element(find.text('New description'))),
        same(editorRoute),
      );

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('lists the new Card first', (tester) async {
      replaceCardsRepository(FakeCardsRepository());
      await pumpApp(tester, initialLocation: AppRoutes.cardsNewPath);

      await _fillAndCreate(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('New title')).dy,
        lessThan(tester.getTopLeft(find.text('Card Title 1')).dy),
      );
    });

    testWidgets('opens another Card afterwards without asking to discard', (
      tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository());
      await pumpApp(tester, initialLocation: AppRoutes.cardsNewPath);

      await _fillAndCreate(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsNothing);
      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );
    });

    testWidgets('asks before discarding a new Card started beside a selected '
        'Card', (tester) async {
      replaceCardsRepository(FakeCardsRepository());
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-2',
      );

      await tester.tap(find.byTooltip('Create card'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Half a title');
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Discard changes?'), findsOneWidget);
    });
  });
}

Future<void> _fillAndCreate(WidgetTester tester) async {
  await tester.enterText(find.byType(AppTextField).first, 'New title');
  await tester.enterText(find.byType(AppTextField).last, 'New description');
  await tester.tap(find.widgetWithText(AppButton, 'Create card'));
  await tester.pumpAndSettle();
}
