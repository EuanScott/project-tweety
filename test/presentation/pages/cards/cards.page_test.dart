import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as cards_repository;
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';
import 'package:project_tweety/presentation/pages/cards/cards.page.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_cards_repository.dart';

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

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -5000),
        5000,
      );
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

      final list = tester.getRect(find.byType(CustomScrollView));
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

  group('Cards page sync row', () {
    useAppHarness();

    Future<void> showSync(
      WidgetTester tester,
      CardsSync sync, {
      Map<String, UnsyncedCardChange> unsyncedChanges = const {},
    }) async {
      tester
          .element(find.byType(Cards))
          .read<CardsBloc>()
          .add(CardsSyncChanged(sync, unsyncedChanges: unsyncedChanges));
      // The bloc emits during the first frame's microtasks, so the second
      // frame is the one that shows the new state. Settling would never end
      // while a sync spinner turns.
      await tester.pump();
      await tester.pump();
    }

    AppButton syncButton(WidgetTester tester, String label) =>
        tester.widget<AppButton>(find.widgetWithText(AppButton, label));

    testWidgets('says every Card is synced by default', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      expect(find.text('All Cards synced'), findsOneWidget);
      expect(syncButton(tester, 'Sync').onPressed, isNotNull);
      expect(find.text('New'), findsNothing);
      expect(find.text('Edited'), findsNothing);
    });

    testWidgets('counts pending changes and marks each unsynced Card', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await showSync(
        tester,
        const CardsSync.pending(changeCount: 4),
        unsyncedChanges: const {
          'card-1': UnsyncedCardChange.created,
          'card-2': UnsyncedCardChange.updated,
        },
      );

      expect(find.text('4 changes on this device only'), findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Card Title 1'),
            matching: find.byType(Card),
          ),
          matching: find.text('New'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Card Title 2'),
            matching: find.byType(Card),
          ),
          matching: find.text('Edited'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('cannot start a second sync while one is running', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await showSync(
        tester,
        const CardsSync.syncing(savedCount: 2, changeCount: 4),
      );

      expect(find.text('2 of 4 changes saved'), findsOneWidget);
      expect(syncButton(tester, 'Syncing').onPressed, isNull);
    });

    testWidgets('names the retry after a partial sync', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await showSync(
        tester,
        const CardsSync.partial(savedCount: 3, changeCount: 4),
      );

      expect(find.text('3 of 4 changes synced'), findsOneWidget);
      expect(find.text('1 change will try again next sync'), findsOneWidget);
    });

    testWidgets('offers to try again when offline', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await showSync(tester, const CardsSync.offline(changeCount: 4));

      expect(find.text("You're offline"), findsOneWidget);
      expect(syncButton(tester, 'Try again').onPressed, isNotNull);
    });

    testWidgets('colours only the icon with the success colour once synced', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await showSync(tester, const CardsSync.synced(changeCount: 4));

      final context = tester.element(find.text('Synced just now'));
      final theme = Theme.of(context);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.cloud_done_outlined)).color,
        DesignStatusColors.of(theme).success,
      );
      expect(
        tester.widget<Text>(find.text('Synced just now')).style?.color,
        isNot(DesignStatusColors.of(theme).success),
      );
    });

    testWidgets('steps to the next state on a long press in debug builds', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.longPress(find.text('All Cards synced'));
      await tester.pump();

      expect(find.text('4 changes on this device only'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Edited'), findsNWidgets(2));
    });

    testWidgets('scrolls away with the Cards', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);
      final restingTop = tester.getTopLeft(find.text('All Cards synced')).dy;

      await tester.drag(find.text('Card Title 3'), const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All Cards synced')).dy,
        lessThan(restingTop),
      );
    });

    testWidgets('scrolls away with the Cards on iOS', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.cardsPath,
        platform: TargetPlatform.iOS,
      );
      final restingTop = tester.getTopLeft(find.text('All Cards synced')).dy;

      await tester.drag(find.text('Card Title 3'), const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All Cards synced')).dy,
        lessThan(restingTop),
      );
    });

    testWidgets('scrolls with the body when there are no Cards', (
      tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);
      final restingTop = tester.getTopLeft(find.text('All Cards synced')).dy;

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('No cards yet')),
      );
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All Cards synced')).dy,
        lessThan(restingTop),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('pulls to refresh when there are no Cards', (tester) async {
      final repository = FakeCardsRepository(cards: const []);
      replaceCardsRepository(repository);
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.fling(find.text('No cards yet'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(repository.collectionReadCount, 2);
    });

    testWidgets('stays on screen while the Cards reload', (tester) async {
      final secondRead = Completer<List<cards_repository.Card>>();
      var reads = 0;
      replaceCardsRepository(
        FakeCardsRepository.collectionOnly(() {
          reads += 1;
          return reads == 1
              ? Future.value(FakeCardsRepository.sampleCards)
              : secondRead.future;
        }),
      );
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      tester
          .element(find.byType(Cards))
          .read<CardsBloc>()
          .add(const CardsStarted());
      await tester.pump();
      await tester.pump();

      expect(find.text('All Cards synced'), findsOneWidget);
      secondRead.complete(FakeCardsRepository.sampleCards);
    });

    testWidgets('shows only the refresh spinner while pulling to refresh', (
      tester,
    ) async {
      final secondRead = Completer<List<cards_repository.Card>>();
      var reads = 0;
      replaceCardsRepository(
        FakeCardsRepository.collectionOnly(() {
          reads += 1;
          return reads == 1
              ? Future.value(FakeCardsRepository.sampleCards)
              : secondRead.future;
        }),
      );
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.fling(find.text('Card Title 1'), const Offset(0, 400), 1000);
      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(reads, 2);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);

      secondRead.complete(FakeCardsRepository.sampleCards);
      await tester.pumpAndSettle();
    });

    testWidgets('lines up with the Cards and keeps every gap at 8', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);
      // The painted surface, not the Card widget, whose box includes its
      // margin.
      Rect cardAround(Finder text) => tester.getRect(
        find.ancestor(of: text, matching: find.byType(Material)).first,
      );

      final row = cardAround(find.text('All Cards synced'));
      final first = cardAround(find.text('Card Title 1'));
      final second = cardAround(find.text('Card Title 2'));

      expect(row.left, first.left);
      expect(row.right, first.right);
      expect(first.top - row.bottom, 8);
      expect(second.top - first.bottom, 8);
    });
  });
}
