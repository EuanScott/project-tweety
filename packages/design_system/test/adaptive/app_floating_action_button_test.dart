import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppFloatingActionButton', () {
    testWidgets('shows the icon with its label and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: AppFloatingActionButton(
              icon: Icons.add,
              semanticLabel: 'Create card',
              onPressed: () => taps++,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byTooltip('Create card'), findsOneWidget);

      await tester.tap(find.byType(AppFloatingActionButton));

      expect(taps, 1);
    });
  });
}
