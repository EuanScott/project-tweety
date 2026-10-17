import 'package:material_ui/material_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/logs/log_entry_details/log_entry_details.page.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Log entries back stack on an iOS phone', () {
    useAppHarness();

    final iOS = TargetPlatformVariant.only(TargetPlatform.iOS);

    Future<void> swipeBack(WidgetTester tester) async {
      await tester.dragFrom(const Offset(5, 450), const Offset(380, 0));
      await tester.pumpAndSettle();
    }

    void expectListOnTop() {
      expect(find.byType(LogEntryDetailsPage), findsNothing);
      expect(find.text('New entry'), findsNothing);
      expect(find.text('Card Title 1'), findsWidgets);
    }

    testWidgets('a log entry opened by deep link swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      expect(find.byType(LogEntryDetailsPage), findsOneWidget);

      await swipeBack(tester);

      expectListOnTop();
      expect(currentRoutePath(tester), AppRoutes.logsPath);
    }, variant: iOS);

    testWidgets('a newly saved log entry swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Fresh title');
      await tester.enterText(find.byType(AppTextField).last, 'Fresh body');
      await tester.tap(find.text('Create entry').last);
      await tester.pumpAndSettle();

      expect(find.byType(LogEntryDetailsPage), findsOneWidget);

      await swipeBack(tester);

      expectListOnTop();
    }, variant: iOS);

    testWidgets(
      'a log entry selected in split view swipes back after folding',
      (tester) async {
        await pumpApp(
          tester,
          surfaceSize: const Size(1000, 900),
          initialLocation: AppRoutes.logsPath,
        );

        await tester.tap(find.text('Card Title 2').first);
        await tester.pumpAndSettle();
        await pumpApp(tester, surfaceSize: const Size(400, 900));

        expect(find.byType(LogEntryDetailsPage), findsOneWidget);

        await swipeBack(tester);

        expectListOnTop();
      },
      variant: iOS,
    );

    testWidgets('an untouched new-log entry editor swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await swipeBack(tester);

      expectListOnTop();
      expect(currentRoutePath(tester), AppRoutes.logsPath);
    }, variant: iOS);

    testWidgets('a new-log entry editor with changes stays open on a swipe', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: AppRoutes.logsPath,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(AppTextField).first, 'Unsaved');
      await tester.pump();
      await swipeBack(tester);

      expect(find.text('Unsaved'), findsOneWidget);
      expect(currentRoutePath(tester), AppRoutes.logsNewPath);
    }, variant: iOS);

    testWidgets('an untouched log entry edit swipes back to the list', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(400, 900),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit entry'));
      await tester.pumpAndSettle();
      await swipeBack(tester);

      expectListOnTop();
    }, variant: iOS);
  });
}
