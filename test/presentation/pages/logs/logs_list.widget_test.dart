import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart'
    as logs_repository;
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/widgets/split_pane_layout.widget.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Log entries list and details', () {
    useAppHarness();

    testWidgets('opens log entry details from the Logs list on compact width', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(400, 800));

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Entry details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        currentRoutePath(tester),
        '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Entry details'), findsNothing);
      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets(
      'dismissing compact Material delete confirmation leaves the log entry unchanged',
      (WidgetTester tester) async {
        final repository = FakeLogsRepository();
        replaceLogsRepository(repository);

        await pumpApp(
          tester,
          surfaceSize: const Size(400, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete entry'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Keep entry'));
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 0);
        expect(find.text('Card Title 1'), findsOneWidget);
        expect(
          currentRoutePath(tester),
          '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );
      },
    );

    testWidgets(
      'confirms wide Cupertino deletion and returns to the Logs root',
      (WidgetTester tester) async {
        final repository = FakeLogsRepository();
        replaceLogsRepository(repository);

        await pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete entry'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);

        await tester.tap(find.text('Delete entry').last);
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 1);
        expect(currentRoutePath(tester), AppRoutes.logsPath);
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
        final repository = FakeLogsRepository(
          deleteError: StateError('failed'),
        );
        replaceLogsRepository(repository);

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        final deleteAction = find.text('מחק רשומה');
        expect(
          Directionality.of(tester.element(deleteAction)),
          TextDirection.rtl,
        );
        await tester.tap(deleteAction);
        await tester.pumpAndSettle();
        await tester.tap(find.text('מחק רשומה').last);
        await tester.pumpAndSettle();

        expect(find.text('לא ניתן למחוק את הרשומה. נסה שוב.'), findsOneWidget);
        expect(find.text('נסה למחוק שוב'), findsOneWidget);
        expect(find.text('Card Title 1'), findsOneWidget);

        await tester.tap(find.text('נסה למחוק שוב'));
        await tester.pumpAndSettle();
        expect(repository.deleteRequestCount, 2);
      },
    );

    testWidgets('keeps compact iOS log entry details below the app bar', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
      );

      await tester.tap(find.text('Logs'));
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

    testWidgets('keeps wide iOS selected log entry details below the app bar', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
      );

      await tester.tap(find.text('Logs'));
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

    testWidgets('opens log entry details from a direct compact route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(find.text('Entry details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsOneWidget);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets(
      'shows the Logs list and details together on wide log entry route',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.text('Card Title 1'), findsWidgets);
        expect(find.text('card-1'), findsOneWidget);
      },
    );

    testWidgets('loads a direct detail route once from the shared Log', (
      WidgetTester tester,
    ) async {
      final logs = Completer<List<logs_repository.LogEntry>>();
      final repository = FakeLogsRepository.collectionOnly(() => logs.future);
      replaceLogsRepository(repository);

      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        settle: false,
      );

      expect(find.byType(AppLoadingIndicator), findsWidgets);
      expect(repository.collectionReadCount, 1);
      expect(repository.detailReadCount, 0);

      logs.complete([FakeLogsRepository.sampleLogs.first]);
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsOneWidget);
      expect(repository.collectionReadCount, 1);
      expect(repository.detailReadCount, 0);
    });

    testWidgets(
      'shows a missing detail for an unknown direct log entry route',
      (WidgetTester tester) async {
        final repository = FakeLogsRepository.collectionOnly(
          () async => const [],
        );
        replaceLogsRepository(repository);

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}missing-card',
        );

        expect(find.text('Entry not found'), findsOneWidget);
        expect(find.text('This entry is not available.'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets(
      'shows a detail failure when the shared collection load fails',
      (WidgetTester tester) async {
        final repository = FakeLogsRepository.collectionOnly(
          () async => throw StateError('collection failed'),
        );
        replaceLogsRepository(repository);

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        expect(find.text('Unable to load entry'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets(
      'scrolls selected log entry into view on wide direct log entry route',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-10',
        );

        final logsList = tester.widget<CustomScrollView>(
          find.byWidgetPredicate(
            (widget) => widget is CustomScrollView && widget.controller != null,
          ),
        );

        expect(logsList.controller!.offset, greaterThan(0));
        expect(find.text('Card Title 10'), findsNWidgets(2));
        expect(find.text('card-10'), findsOneWidget);
      },
    );

    testWidgets(
      'scrolling log entry details does not scroll the Logs list on wide iOS layout',
      (WidgetTester tester) async {
        await pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(1000, 800),
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-10',
        );

        // byType matches the exact type, so it skips the page's
        // NestedScrollView, whose inner view subclasses CustomScrollView.
        final logsList = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        final initialOffset = logsList.controller!.offset;

        expect(initialOffset, greaterThan(0));

        await tester.drag(find.text('card-10'), const Offset(0, 300));
        await tester.pumpAndSettle();

        expect(logsList.controller!.offset, initialOffset);

        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.text('card-10')),
            scrollDelta: const Offset(0, 300),
          ),
        );
        await tester.pumpAndSettle();

        expect(logsList.controller!.offset, initialOffset);
      },
    );

    testWidgets('wide iOS Logs disable page-level sliver scrolling', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-10',
      );

      final nestedScrollView = tester.widget<NestedScrollView>(
        find.byType(NestedScrollView),
      );

      expect(nestedScrollView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('selects a log entry through the wide detail route', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, surfaceSize: const Size(900, 800));

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('Select an entry'), findsOneWidget);

      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppPaneHeader),
          matching: find.text('Entry details'),
        ),
        findsOneWidget,
      );
      expect(find.text('card-1'), findsOneWidget);
      expect(
        currentRoutePath(tester),
        '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.byIcon(Icons.cabin));
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsNothing);
      expect(find.text('Select an entry'), findsOneWidget);
    });

    testWidgets('replaces the wide log entry detail route on later selection', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(
        currentRoutePath(tester),
        '${AppRoutes.logsDetailFullPathPrefix}card-2',
      );
      expect(find.text('card-1'), findsNothing);
      expect(find.text('card-2'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    // UI Responsiveness & Visual Tests (previously manual-only)

    testWidgets('truncates long log entry content in list items', (
      WidgetTester tester,
    ) async {
      final longLogEntry = logs_repository.LogEntry(
        id: 'long-card',
        title: 'A' * 100,
        description: 'B' * 300,
      );
      replaceLogsRepository(FakeLogsRepository(logs: [longLogEntry]));

      await pumpApp(tester, surfaceSize: const Size(400, 800));
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      final logEntryTexts = find.descendant(
        of: find
            .ancestor(
              of: find.text(longLogEntry.title),
              matching: find.byType(Card),
            )
            .first,
        matching: find.byType(Text),
      );

      final titleText = tester.widget<Text>(logEntryTexts.first);
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);

      final descriptionText = tester.widget<Text>(logEntryTexts.last);
      expect(descriptionText.maxLines, 2);
      expect(descriptionText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('selected log entry shows primary border in list', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      final theme = Theme.of(
        tester.element(find.byType(CustomScrollView).first),
      );
      final selectedLogEntry = tester.widget<Card>(
        find.byWidgetPredicate((widget) {
          if (widget is! Card) return false;
          final border = (widget.shape as RoundedRectangleBorder?)?.side;
          return border?.color == theme.colorScheme.primary;
        }),
      );

      expect(selectedLogEntry, isNotNull);
    });

    testWidgets('pull-to-refresh during load does not duplicate requests', (
      WidgetTester tester,
    ) async {
      final repository = FakeLogsRepository();
      replaceLogsRepository(repository);

      await pumpApp(tester, surfaceSize: const Size(400, 800));
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      // Start a refresh while already loading
      final initialCount = repository.collectionReadCount;
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(repository.collectionReadCount, initialCount + 1);
    });

    testWidgets('error state retry reloads the Log', (
      WidgetTester tester,
    ) async {
      final repository = FakeLogsRepository(
        readError: StateError('load failed'),
      );
      replaceLogsRepository(repository);

      await pumpApp(tester, surfaceSize: const Size(400, 800));
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load logs right now.'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(repository.collectionReadCount, 2);
    });

    const translatedErrors = {
      'es': (
        tab: 'Registros',
        message: 'No se pudieron cargar los registros ahora mismo.',
        retry: 'Reintentar',
      ),
      'he': (
        tab: 'יומן',
        message: 'לא ניתן לטעון את היומן כרגע.',
        retry: 'נסה שוב',
      ),
    };
    for (final MapEntry(key: code, value: expected)
        in translatedErrors.entries) {
      testWidgets('error state shows translated text for $code', (
        WidgetTester tester,
      ) async {
        replaceAppPreferencesRepository(
          FakeAppPreferencesRepository(AppPreferences(languageCode: code)),
        );
        replaceLogsRepository(
          FakeLogsRepository(readError: StateError('load failed')),
        );

        await pumpApp(tester, surfaceSize: const Size(400, 800));
        await tester.tap(find.text(expected.tab));
        await tester.pumpAndSettle();

        expect(find.text(expected.message), findsOneWidget);
        expect(find.text(expected.retry), findsOneWidget);
        expect(find.text('Unable to load logs right now.'), findsNothing);
        expect(find.text('Retry'), findsNothing);
      });
    }

    testWidgets('tablet portrait mode shows split pane layout', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(768, 1024),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(SplitPaneLayout), findsOneWidget);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
    });

    testWidgets(
      'previews a multi-paragraph description on one flowing line and '
      'shows its paragraphs in the details',
      (WidgetTester tester) async {
        const description = 'First line\nSecond line\r\n\n  \nThird line';
        replaceLogsRepository(
          FakeLogsRepository(
            logs: const [
              logs_repository.LogEntry(
                id: 'card-1',
                title: 'Paragraphs',
                description: description,
              ),
            ],
          ),
        );

        await pumpApp(tester, initialLocation: AppRoutes.logsPath);

        expect(find.text('First line Second line Third line'), findsOneWidget);

        await tester.tap(find.text('Paragraphs'));
        await tester.pumpAndSettle();

        expect(find.text(description), findsOneWidget);
      },
    );

    testWidgets('cuts a long multi-paragraph preview at two lines with an '
        'ellipsis', (WidgetTester tester) async {
      final paragraphs = List<String>.filled(6, 'A paragraph long enough');
      replaceLogsRepository(
        FakeLogsRepository(
          logs: [
            logs_repository.LogEntry(
              id: 'card-1',
              title: 'Long',
              description: paragraphs.join('\n\n'),
            ),
          ],
        ),
      );

      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      final preview = tester.renderObject<RenderParagraph>(
        find.text(paragraphs.join(' ')),
      );
      expect(preview.didExceedMaxLines, isTrue);
      expect(preview.overflow, TextOverflow.ellipsis);
    });
  });
}
