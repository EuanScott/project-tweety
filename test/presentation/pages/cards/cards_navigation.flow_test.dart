import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/cards/card_details/card_details.page.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';

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

      final listPage = _cardsPageState(tester);

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/cards/card-2');
      expect(_cardsPageState(tester), same(listPage));
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('shows no iOS back button when the region shows both panes', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('system back clears the selection when the region shows both '
        'panes', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.byType(CardDetailsEmptyState), findsOneWidget);
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

      expect(_canPop(tester), isTrue);

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

      final listPage = _cardsPageState(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(
        _cardsPageState(tester),
        same(listPage),
        reason:
            'creating a card replaced the visible page, which plays a '
            'transition over a layout that never changed',
      );
      expect(find.byType(BackButton), findsNothing);
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

      final listPage = _cardsPageState(tester);

      await tester.tap(find.text('Create card').first);
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.cardsNewPath);
      expect(_cardsPageState(tester), same(listPage));
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

    testWidgets('shows pushed details beside the list when the region becomes '
        'split', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(_canPop(tester), isTrue);

      await pumpApp(tester, surfaceSize: const Size(1000, 900));

      expect(currentRoutePath(tester), '/cards/card-2');
      expect(find.byType(CardDetailsPage), findsNothing);
      expect(find.byType(CardDetailsContent), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });
  });
}

State<Cards> _cardsPageState(WidgetTester tester) {
  return tester.state(find.byType(Cards));
}

bool _canPop(WidgetTester tester) {
  return GoRouter.of(tester.element(find.byType(Navigator).last)).canPop();
}
