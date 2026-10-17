import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('LogsDraftDiscardGuard', () {
    useAppHarness();

    testWidgets(
      'shows discard confirmation dialog when navigating away from dirty create draft',
      (WidgetTester tester) async {
        await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.tap(find.text('Logs'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Discard changes?'), findsOneWidget);
      },
    );

    testWidgets(
      'shows discard confirmation dialog when navigating away from dirty edit draft',
      (WidgetTester tester) async {
        replaceLogsRepository(FakeLogsRepository());

        await pumpApp(
          tester,
          initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Edit entry'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(AppTextField).first,
          'Updated title',
        );
        await tester.tap(find.text('Logs'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Discard changes?'), findsOneWidget);
      },
    );

    testWidgets('allows navigation without dialog when draft is clean', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, initialLocation: AppRoutes.logsNewPath);

      // Don't enter any text - draft is clean
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(currentRoutePath(tester), AppRoutes.logsPath);
    });
  });
}
