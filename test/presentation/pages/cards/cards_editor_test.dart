import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as cards_repository;
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_cards_repository.dart';

void main() {
  group('Cards editor', () {
    useAppHarness();

    testWidgets('edits a persisted card and keeps its detail route', (
      WidgetTester tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository());

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit card'));
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.enterText(find.byType(AppTextField).first, 'Updated title');
      await tester.enterText(
        find.byType(AppTextField).last,
        'Updated description',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );
      expect(find.text('Updated title'), findsOneWidget);
      expect(find.text('Updated description'), findsOneWidget);
      expect(find.text('Edit card'), findsOneWidget);
    });

    testWidgets(
      'retains a missing-target edit draft and offers return to cards',
      (WidgetTester tester) async {
        replaceCardsRepository(
          FakeCardsRepository(
            updateError: const cards_repository.CardNotFoundException('card-1'),
          ),
        );

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Edit card'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        expect(find.text('Card no longer exists.'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .controller
              .text,
          'Raw title',
        );
        await tester.tap(find.text('Return to cards'));
        await tester.pumpAndSettle();

        expect(currentRoutePath(tester), AppRoutes.cardsPath);
      },
    );

    testWidgets('creates a card from the compact editor route', (
      WidgetTester tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(tester, initialLocation: '${AppRoutes.cardsPath}/new');

      expect(find.text('New card'), findsWidgets);
      expect(find.byType(AppTextField), findsNWidgets(2));

      await tester.enterText(find.byType(AppTextField).first, 'New title');
      await tester.enterText(find.byType(AppTextField).last, 'New description');
      await tester.tap(find.text('Create card'));
      await tester.pumpAndSettle();

      expect(
        currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}created-card',
      );
      expect(find.text('New title'), findsOneWidget);
      expect(find.text('New description'), findsOneWidget);
    });

    testWidgets('renders the editor in the wide Cupertino secondary pane', (
      WidgetTester tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: AppRoutes.cardsNewFullPath,
        platform: TargetPlatform.iOS,
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
      expect(find.text('New card'), findsWidgets);
    });

    testWidgets('renders the creation editor right-to-left in Hebrew', (
      WidgetTester tester,
    ) async {
      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(const AppPreferences(languageCode: 'he')),
      );
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      final title = find.text('כרטיס חדש').first;
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);
      expect(find.text('צור כרטיס'), findsOneWidget);
    });

    testWidgets('opens the editor from the empty list call to action', (
      WidgetTester tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      expect(find.text('No cards yet'), findsOneWidget);
      await tester.tap(find.text('Create card'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsNewFullPath);
    });

    testWidgets('opens the editor from the Cards toolbar action', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.tap(find.byTooltip('Create card'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsNewFullPath);
    });

    testWidgets('keeps a dirty create draft when discard is dismissed', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsNewFullPath);
      expect(
        tester
            .widget<AppTextField>(find.byType(AppTextField).first)
            .controller
            .text,
        'Raw title',
      );
    });

    testWidgets('discards a dirty create draft after confirmation', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('guards and de-duplicates dirty active-tab resets', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cards'));
      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('shows and updates validation errors after create submission', (
      WidgetTester tester,
    ) async {
      replaceCardsRepository(FakeCardsRepository(cards: const []));

      await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.tap(find.text('Create card'));
      await tester.pump();

      expect(find.text('Enter a title.'), findsOneWidget);
      expect(find.text('Enter a description.'), findsOneWidget);

      await tester.enterText(find.byType(AppTextField).first, 'Title');
      await tester.pump();

      expect(find.text('Enter a title.'), findsNothing);
      expect(find.text('Enter a description.'), findsOneWidget);
    });

    testWidgets(
      'retains editor input and inline feedback when creation fails',
      (WidgetTester tester) async {
        replaceCardsRepository(
          FakeCardsRepository(
            cards: const [],
            createError: StateError('write failed'),
          ),
        );

        await pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.enterText(
          find.byType(AppTextField).last,
          'Raw description',
        );
        await tester.tap(find.text('Create card'));
        await tester.pumpAndSettle();

        expect(find.text('Unable to save card. Try again.'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .controller
              .text,
          'Raw title',
        );
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).last)
              .controller
              .text,
          'Raw description',
        );
      },
    );
  });
}
