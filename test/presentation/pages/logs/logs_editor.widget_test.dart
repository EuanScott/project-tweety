import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart'
    as logs_repository;
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Log entries editor', () {
    useAppHarness();

    testWidgets('edits a persisted log entry and keeps its detail route', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository());

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit entry'));
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
        '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );
      expect(find.text('Updated title'), findsOneWidget);
      expect(find.text('Updated description'), findsOneWidget);
      expect(find.text('Edit entry'), findsOneWidget);
    });

    testWidgets(
      'retains a missing-target edit draft and offers return to Logs',
      (WidgetTester tester) async {
        replaceLogsRepository(
          FakeLogsRepository(
            updateError: const logs_repository.LogEntryNotFoundException(
              'card-1',
            ),
          ),
        );

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Edit entry'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        expect(find.text('Entry no longer exists.'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .controller
              .text,
          'Raw title',
        );
        await tester.tap(find.text('Return to logs'));
        await tester.pumpAndSettle();

        expect(currentRoutePath(tester), AppRoutes.logsPath);
      },
    );

    testWidgets('creates a log entry from the compact editor route', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(tester, initialLocation: '${AppRoutes.logsPath}/new');

      expect(find.text('New entry'), findsWidgets);
      expect(find.byType(AppTextField), findsNWidgets(2));

      await tester.enterText(find.byType(AppTextField).first, 'New title');
      await tester.enterText(find.byType(AppTextField).last, 'New description');
      await tester.tap(find.text('Create entry'));
      await tester.pumpAndSettle();

      expect(
        currentRoutePath(tester),
        '${AppRoutes.logsDetailFullPathPrefix}created-card',
      );
      expect(find.text('New title'), findsOneWidget);
      expect(find.text('New description'), findsOneWidget);
    });

    testWidgets('renders the editor in the wide Cupertino secondary pane', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: AppRoutes.logsNewPath,
        platform: TargetPlatform.iOS,
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
      expect(find.text('New entry'), findsWidgets);
    });

    testWidgets('renders the creation editor right-to-left in Hebrew', (
      WidgetTester tester,
    ) async {
      replaceAppPreferencesRepository(
        FakeAppPreferencesRepository(const AppPreferences(languageCode: 'he')),
      );
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      final title = find.text('רשומה חדשה').first;
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);
      expect(find.text('צור רשומה'), findsOneWidget);
    });

    testWidgets('opens the editor from the empty list call to action', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      expect(find.text('No entries yet'), findsOneWidget);
      await tester.tap(find.text('Create entry'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
    });

    testWidgets('opens the editor from the Logs toolbar action', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsPath);

      await tester.tap(find.byTooltip('Create entry'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
    });

    testWidgets('keeps a dirty create draft when discard is dismissed', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
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
      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsPath);
    });

    testWidgets('guards and de-duplicates dirty active-tab resets', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Logs'));
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsPath);
    });

    testWidgets('shows and updates validation errors after create submission', (
      WidgetTester tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      await tester.tap(find.text('Create entry'));
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
        replaceLogsRepository(
          FakeLogsRepository(
            logs: const [],
            createError: StateError('write failed'),
          ),
        );

        await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.enterText(
          find.byType(AppTextField).last,
          'Raw description',
        );
        await tester.tap(find.text('Create entry'));
        await tester.pumpAndSettle();

        expect(find.text('Unable to save entry. Try again.'), findsOneWidget);
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

    // UI Responsiveness Test (previously manual-only)
    testWidgets('edit button is disabled during update submission', (
      WidgetTester tester,
    ) async {
      final repository = FakeLogsRepository.gated(
        logs: [FakeLogsRepository.sampleLogs.first],
      );
      replaceLogsRepository(repository);

      await pumpApp(
        tester,
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit entry'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Updated title');

      final saveButtonBefore = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Save changes'),
      );
      expect(saveButtonBefore.onPressed, isNotNull);

      await tester.tap(find.text('Save changes'));
      await tester.pump();

      final saveButtonDuring = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Save changes'),
      );
      expect(saveButtonDuring.onPressed, isNull);

      repository.completeUpdate(
        logs_repository.LogEntry(
          id: 'card-1',
          title: 'Updated title',
          description: FakeLogsRepository.sampleLogs.first.description,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Updated title'), findsOneWidget);
    });
  });
}
