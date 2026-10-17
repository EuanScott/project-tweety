import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/logs/log_entry_details/log_entry_details.page.dart';
import 'package:project_tweety/presentation/pages/logs/logs.page.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('Log entries selection navigation', () {
    useAppHarness();

    testWidgets('keeps a single page when the region shows both panes', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      final listPage = _logsPageState(tester);

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/logs/card-2');
      expect(_logsPageState(tester), same(listPage));
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('shows no iOS back button when the region shows both panes', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
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
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.logsPath);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.byType(LogEntryDetailsEmptyState), findsOneWidget);
    });

    testWidgets('pushes a details page when the region shows one pane', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), '/logs/card-2');
      expect(_canPop(tester), isTrue);
    });
    testWidgets('offers a way back to the list when details open cold', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(_canPop(tester), isTrue);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(currentRoutePath(tester), AppRoutes.logsPath);
    });

    testWidgets(
      'keeps a single page when creating a log entry in a split region',
      (tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(1000, 900),
          initialLocation: AppRoutes.logsPath,
        );

        final listPage = _logsPageState(tester);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(currentRoutePath(tester), AppRoutes.logsNewPath);
        expect(
          _logsPageState(tester),
          same(listPage),
          reason:
              'creating a log entry replaced the visible page, which plays a '
              'transition over a layout that never changed',
        );
        expect(find.byType(BackButton), findsNothing);
      },
    );

    testWidgets('keeps a single page when creating from the empty state', (
      tester,
    ) async {
      replaceLogsRepository(FakeLogsRepository(logs: const []));

      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      final listPage = _logsPageState(tester);

      await tester.tap(find.text('Create entry').first);
      await tester.pump();

      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
      expect(_logsPageState(tester), same(listPage));
    });

    testWidgets(
      'pushes the editor when creating a log entry in a compact region',
      (tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(400, 900),
          initialLocation: AppRoutes.logsPath,
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(currentRoutePath(tester), AppRoutes.logsNewPath);
        expect(_canPop(tester), isTrue);
      },
    );

    testWidgets('shows pushed details beside the list when the region becomes '
        'split', (tester) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(_canPop(tester), isTrue);

      await pumpApp(tester, surfaceSize: const Size(1000, 900));

      expect(currentRoutePath(tester), '/logs/card-2');
      expect(find.byType(LogEntryDetailsPage), findsNothing);
      expect(find.byType(LogEntryDetailsContent), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });
  });
}

State<Logs> _logsPageState(WidgetTester tester) {
  return tester.state(find.byType(Logs));
}

bool _canPop(WidgetTester tester) {
  return GoRouter.of(tester.element(find.byType(Navigator).last)).canPop();
}
