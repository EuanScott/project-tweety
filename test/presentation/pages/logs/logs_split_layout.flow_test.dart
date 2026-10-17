import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Log entries split layout', () {
    useAppHarness();

    testWidgets('aligns the create editor with the details view', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: '${AppRoutes.logsDetailFullPathPrefix}card-1',
      );

      final detailsBounds = tester.getRect(
        find.widgetWithText(AppButton, 'Edit entry'),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final createBounds = tester.getRect(
        find.widgetWithText(AppButton, 'Create entry'),
      );

      expect(createBounds.left, detailsBounds.left);
      expect(createBounds.right, detailsBounds.right);
    });

    testWidgets('gives unselected log entries a visible surface edge', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.logsPath,
      );

      final logEntry = tester.widget<Card>(find.byType(Card).first);
      final shape = logEntry.shape as RoundedRectangleBorder?;

      expect(
        shape?.side.color ??
            Theme.of(tester.element(find.byType(Card).first)).cardTheme.shape,
        isNot(Colors.transparent),
      );
    });
  });
}
