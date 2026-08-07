import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as cards_repository;
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('Cards list and details', () {
    useAppHarness();

    testWidgets('opens card details from the cards list on compact width', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(400, 800));

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsNothing);
      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets(
      'dismissing compact Material delete confirmation leaves the card unchanged',
      (WidgetTester tester) async {
        final repository = FakeCardsRepository();
        replaceCardsRepository(repository);

        await pumpApp(
          tester,
          surfaceSize: const Size(400, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete card'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Keep card'));
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 0);
        expect(find.text('Card Title 1'), findsOneWidget);
        expect(
          currentRoutePath(tester),
          '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );
      },
    );

    testWidgets(
      'confirms wide Cupertino deletion and returns to the cards root',
      (WidgetTester tester) async {
        final repository = FakeCardsRepository();
        replaceCardsRepository(repository);

        await pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete card'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);

        await tester.tap(find.text('Delete card').last);
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 1);
        expect(currentRoutePath(tester), AppRoutes.cardsPath);
        expect(find.text('Card Title 1'), findsNothing);
      },
    );

    testWidgets(
      'keeps RTL details visible and offers deletion retry on failure',
      (WidgetTester tester) async {
        replaceAppPreferencesRepository(
          FakeAppPreferencesRepository(
            const AppPreferences(languageCode: 'he'),
          ),
        );
        final repository = FakeCardsRepository(
          deleteError: StateError('failed'),
        );
        replaceCardsRepository(repository);

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        final deleteAction = find.text('מחק כרטיס');
        expect(
          Directionality.of(tester.element(deleteAction)),
          TextDirection.rtl,
        );
        await tester.tap(deleteAction);
        await tester.pumpAndSettle();
        await tester.tap(find.text('מחק כרטיס').last);
        await tester.pumpAndSettle();

        expect(find.text('לא ניתן למחוק את הכרטיס. נסה שוב.'), findsOneWidget);
        expect(find.text('נסה למחוק שוב'), findsOneWidget);
        expect(find.text('Card Title 1'), findsOneWidget);

        await tester.tap(find.text('נסה למחוק שוב'));
        await tester.pumpAndSettle();
        expect(repository.deleteRequestCount, 2);
      },
    );

    testWidgets('keeps compact iOS card details below the app bar', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
      );

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      final navigationBarBottom = tester
          .getRect(find.byType(CupertinoNavigationBar))
          .bottom;
      final detailsTitleTop = tester
          .getRect(find.text('Card Title 1').last)
          .top;

      expect(detailsTitleTop, greaterThanOrEqualTo(navigationBarBottom));
    });

    testWidgets('keeps wide iOS selected card details below the app bar', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
      );

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      final detailsTitleTop = tester
          .getRect(find.text('Card Title 1').last)
          .top;

      expect(
        detailsTitleTop,
        greaterThanOrEqualTo(kMinInteractiveDimensionCupertino),
      );
    });

    testWidgets('opens card details from a direct compact route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.text('Card details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsOneWidget);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('shows cards list and details together on wide card route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
    });

    testWidgets(
      'loads a direct detail route once from the shared cards collection',
      (WidgetTester tester) async {
        final cards = Completer<List<cards_repository.Card>>();
        final repository = FakeCardsRepository.collectionOnly(
          () => cards.future,
        );
        replaceCardsRepository(repository);

        await pumpApp(
          tester,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
          settle: false,
        );

        expect(find.byType(AppLoadingIndicator), findsWidgets);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);

        cards.complete([FakeCardsRepository.sampleCards.first]);
        await tester.pumpAndSettle();

        expect(find.text('card-1'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets('shows a missing detail for an unknown direct card route', (
      WidgetTester tester,
    ) async {
      final repository = FakeCardsRepository.collectionOnly(
        () async => const [],
      );
      replaceCardsRepository(repository);

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}missing-card',
      );

      expect(find.text('Card not found'), findsOneWidget);
      expect(find.text('This card is not available.'), findsOneWidget);
      expect(repository.collectionReadCount, 1);
      expect(repository.detailReadCount, 0);
    });

    testWidgets(
      'shows a detail failure when the shared collection load fails',
      (WidgetTester tester) async {
        final repository = FakeCardsRepository.collectionOnly(
          () async => throw StateError('collection failed'),
        );
        replaceCardsRepository(repository);

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        expect(find.text('Unable to load card'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets('scrolls selected card into view on wide direct card route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
      );

      final cardsList = tester.widget<ListView>(
        find.byWidgetPredicate(
          (widget) => widget is ListView && widget.controller != null,
        ),
      );

      expect(cardsList.controller!.offset, greaterThan(0));
      expect(find.text('Card Title 10'), findsNWidgets(2));
      expect(find.text('card-10'), findsOneWidget);
    });

    testWidgets(
      'scrolling card details does not scroll cards list on wide iOS layout',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(1000, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
        );

        final cardsList = tester.widget<ListView>(
          find.byWidgetPredicate(
            (widget) => widget is ListView && widget.controller != null,
          ),
        );
        final initialOffset = cardsList.controller!.offset;

        expect(initialOffset, greaterThan(0));

        await tester.drag(find.text('card-10'), const Offset(0, 300));
        await tester.pumpAndSettle();

        expect(cardsList.controller!.offset, initialOffset);

        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.text('card-10')),
            scrollDelta: const Offset(0, 300),
          ),
        );
        await tester.pumpAndSettle();

        expect(cardsList.controller!.offset, initialOffset);
      },
    );

    testWidgets('wide iOS cards disable page-level sliver scrolling', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
      );

      final nestedScrollView = tester.widget<NestedScrollView>(
        find.byType(NestedScrollView),
      );

      expect(nestedScrollView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('selects a card through the wide detail route', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(900, 800));

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      expect(find.text('Select a card'), findsOneWidget);

      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsNothing);
      expect(find.text('card-1'), findsOneWidget);
      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsNothing);
      expect(find.text('Select a card'), findsOneWidget);
    });

    testWidgets('replaces the wide card detail route on later selection', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-2',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
      expect(find.text('card-1'), findsNothing);
      expect(find.text('card-2'), findsNothing);
    });
  });
}
