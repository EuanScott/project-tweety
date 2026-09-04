import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

import '../../../support/app_harness.dart';

void main() {
  group('Cards split layout', () {
    useAppHarness();

    testWidgets('aligns the create editor with the details view', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      final detailsBounds = tester.getRect(
        find.widgetWithText(AppButton, 'Edit card'),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final createBounds = tester.getRect(
        find.widgetWithText(AppButton, 'Create card'),
      );

      expect(createBounds.left, detailsBounds.left);
      expect(createBounds.right, detailsBounds.right);
    });

    testWidgets('gives unselected cards a visible surface edge', (
      tester,
    ) async {
      await pumpApp(
        tester,
        surfaceSize: const Size(1000, 900),
        initialLocation: AppRoutes.cardsPath,
      );

      final card = tester.widget<Card>(find.byType(Card).first);
      final shape = card.shape as RoundedRectangleBorder?;

      expect(
        shape?.side.color ?? Theme.of(
          tester.element(find.byType(Card).first),
        ).cardTheme.shape,
        isNot(Colors.transparent),
      );
    });
  });
}
