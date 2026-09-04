import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('Cards selection navigation', () {
    useAppHarness();

    testWidgets('keeps a single page when the region shows both panes', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/cards/card-2');
      expect(_canPop(tester), isFalse);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('pushes a details page when the region shows one pane', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/cards/card-2');
      expect(_canPop(tester), isTrue);
    });
    testWidgets('offers a way back to the list when details open cold', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(_canPop(tester), isFalse);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('keeps a single page when creating a card in a split region', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(
        _canPop(tester),
        isFalse,
        reason: 'creating a card pushed a page that then had to be replaced, '
            'which plays a transition over a layout that never changed',
      );
    });

    testWidgets('keeps a single page when creating from the empty state', (
      tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Create card').first);
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(_canPop(tester), isFalse);
    });

    testWidgets('pushes the editor when creating a card in a compact region', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(_canPop(tester), isTrue);
    });

    testWidgets('flattens a pushed details page when the region becomes split',
        (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(_canPop(tester), isTrue);

      await tester.binding.setSurfaceSize(const Size(1000, 900));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/cards/card-2');
      expect(_canPop(tester), isFalse);
    });
  });
}

bool _canPop(WidgetTester tester) {
  return GoRouter.of(
    tester.element(find.byType(Navigator).last),
  ).canPop();
}
