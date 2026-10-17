import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart'
    as logs_repository;
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';
import 'package:project_tweety/presentation/pages/logs/logs.page.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Logs page create action', () {
    useAppHarness();

    testWidgets('is a floating action button on Android', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.logsPath,
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
      expect(find.byTooltip('Create entry'), findsOneWidget);
    });

    testWidgets('stays in the navigation bar on iOS', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.logsPath,
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

    testWidgets('lets the last log entry scroll clear of the floating action '
        'button', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.android,
      );

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -5000),
        5000,
      );
      await tester.pumpAndSettle();

      final lastLogEntry = find.ancestor(
        of: find.text('Card Title 10'),
        matching: find.byType(Card),
      );

      expect(
        tester.getRect(lastLogEntry).bottom,
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
        initialLocation: AppRoutes.logsPath,
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
        initialLocation: AppRoutes.logsPath,
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
        initialLocation: AppRoutes.logsNewPath,
        platform: TargetPlatform.android,
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('opens the log entry editor from the floating action button', (
      tester,
    ) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.android,
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('Logs page sync row', () {
    useAppHarness();

    Future<void> showSync(
      WidgetTester tester,
      LogsSync sync, {
      Map<String, UnsyncedLogEntryChange> unsyncedChanges = const {},
    }) async {
      tester
          .element(find.byType(Logs))
          .read<LogsBloc>()
          .add(LogsSyncChanged(sync, unsyncedChanges: unsyncedChanges));
      // The bloc emits during the first frame's microtasks, so the second
      // frame is the one that shows the new state. Settling would never end
      // while a sync spinner turns.
      await tester.pump();
      await tester.pump();
    }

    AppButton syncButton(WidgetTester tester, String label) =>
        tester.widget<AppButton>(find.widgetWithText(AppButton, label));

    testWidgets('says every log entry is synced by default', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      expect(find.text('All logs synced'), findsOneWidget);
      expect(syncButton(tester, 'Sync').onPressed, isNotNull);
      expect(find.text('New'), findsNothing);
      expect(find.text('Edited'), findsNothing);
    });

    testWidgets('counts pending changes and marks each unsynced log entry', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await showSync(
        tester,
        const LogsSync.pending(changeCount: 4),
        unsyncedChanges: const {
          'card-1': UnsyncedLogEntryChange.created,
          'card-2': UnsyncedLogEntryChange.updated,
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
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await showSync(
        tester,
        const LogsSync.syncing(savedCount: 2, changeCount: 4),
      );

      expect(find.text('2 of 4 changes saved'), findsOneWidget);
      expect(syncButton(tester, 'Syncing').onPressed, isNull);
    });

    testWidgets('names the retry after a partial sync', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await showSync(
        tester,
        const LogsSync.partial(savedCount: 3, changeCount: 4),
      );

      expect(find.text('3 of 4 changes synced'), findsOneWidget);
      expect(find.text('1 change will try again next sync'), findsOneWidget);
    });

    testWidgets('offers to try again when offline', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await showSync(tester, const LogsSync.offline(changeCount: 4));

      expect(find.text("You're offline"), findsOneWidget);
      expect(syncButton(tester, 'Retry').onPressed, isNotNull);
    });

    testWidgets('colours only the icon with the success colour once synced', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await showSync(tester, const LogsSync.synced(changeCount: 4));

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

    testWidgets('pressing Sync pushes the pending changes', (tester) async {
      final repository = FakeLogsRepository()
        ..syncSummary = const logs_repository.LogsSyncSummary(
          pendingChanges: {
            'card-1': logs_repository.PendingLogEntryChange.updated,
          },
        )
        ..summaryAfterSync = const logs_repository.LogsSyncSummary()
        ..syncResult = const logs_repository.LogsSyncResult(
          changeCount: 1,
          savedCount: 1,
        );
      replaceLogsRepository(repository);
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await tester.tap(find.widgetWithText(AppButton, 'Sync'));
      await tester.pump();
      await tester.pump();

      expect(repository.syncRequestCount, 1);
      expect(find.text('Synced just now'), findsOneWidget);
      expect(find.text('Edited'), findsNothing);
    });

    testWidgets('scrolls away with the log entries', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);
      final restingTop = tester.getTopLeft(find.text('All logs synced')).dy;

      await tester.drag(find.text('Card Title 3'), const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All logs synced')).dy,
        lessThan(restingTop),
      );
    });

    testWidgets('scrolls away with the log entries on iOS', (tester) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.logsPath,
        platform: TargetPlatform.iOS,
      );
      final restingTop = tester.getTopLeft(find.text('All logs synced')).dy;

      await tester.drag(find.text('Card Title 3'), const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All logs synced')).dy,
        lessThan(restingTop),
      );
    });

    testWidgets('scrolls with the body when there are no log entries', (
      tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);
      final restingTop = tester.getTopLeft(find.text('All logs synced')).dy;

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('No entries yet')),
      );
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('All logs synced')).dy,
        lessThan(restingTop),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('pulls to refresh when there are no log entries', (
      tester,
    ) async {
      final repository = FakeLogsRepository(logs: const []);
      replaceLogsRepository(repository);
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await tester.fling(
        find.text('No entries yet'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(repository.collectionReadCount, 2);
    });

    testWidgets('stays on screen while the log entries reload', (tester) async {
      final secondRead = Completer<List<logs_repository.LogEntry>>();
      var reads = 0;
      replaceLogsRepository(
        FakeLogsRepository.collectionOnly(() {
          reads += 1;
          return reads == 1
              ? Future.value(FakeLogsRepository.sampleLogs)
              : secondRead.future;
        }),
      );
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      tester
          .element(find.byType(Logs))
          .read<LogsBloc>()
          .add(const LogsStarted());
      await tester.pump();
      await tester.pump();

      expect(find.text('All logs synced'), findsOneWidget);
      secondRead.complete(FakeLogsRepository.sampleLogs);
    });

    testWidgets('shows only the refresh spinner while pulling to refresh', (
      tester,
    ) async {
      final secondRead = Completer<List<logs_repository.LogEntry>>();
      var reads = 0;
      replaceLogsRepository(
        FakeLogsRepository.collectionOnly(() {
          reads += 1;
          return reads == 1
              ? Future.value(FakeLogsRepository.sampleLogs)
              : secondRead.future;
        }),
      );
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await tester.fling(find.text('Card Title 1'), const Offset(0, 400), 1000);
      for (var frame = 0; frame < 5; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(reads, 2);
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);

      secondRead.complete(FakeLogsRepository.sampleLogs);
      await tester.pumpAndSettle();
    });

    testWidgets('lines up with the log entries and keeps every gap at 8', (
      tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);
      // The painted surface, not the log entry widget, whose box includes its
      // margin.
      Rect logEntryAround(Finder text) => tester.getRect(
        find.ancestor(of: text, matching: find.byType(Material)).first,
      );

      final row = logEntryAround(find.text('All logs synced'));
      final first = logEntryAround(find.text('Card Title 1'));
      final second = logEntryAround(find.text('Card Title 2'));

      expect(row.left, first.left);
      expect(row.right, first.right);
      expect(first.top - row.bottom, 8);
      expect(second.top - first.bottom, 8);
    });
  });
}
