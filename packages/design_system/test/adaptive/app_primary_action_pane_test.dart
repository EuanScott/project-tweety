import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _contentKey = Key('content');

Widget _host(
  TargetPlatform platform, {
  required ValueChanged<double> onClearance,
  bool hasAction = true,
  bool isActionVisible = true,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Scaffold(
      body: AppPrimaryActionPane(
        isActionVisible: isActionVisible,
        action: hasAction
            ? AppFloatingActionButton(
                icon: Icons.add,
                semanticLabel: 'Create card',
                onPressed: () {},
              )
            : null,
        child: Builder(
          builder: (context) {
            onClearance(AppPrimaryActionPane.bottomClearanceOf(context));
            return const SizedBox.expand(key: _contentKey);
          },
        ),
      ),
    ),
  );
}

void main() {
  group('AppPrimaryActionPane', () {
    testWidgets('floats the action at the bottom end of the pane on '
        'Android', (tester) async {
      var clearance = -1.0;
      await tester.pumpWidget(
        _host(
          TargetPlatform.android,
          onClearance: (value) => clearance = value,
        ),
      );

      final pane = tester.getRect(find.byKey(_contentKey));
      final button = tester.getRect(find.byType(FloatingActionButton));

      expect(pane.right - button.right, 16);
      expect(pane.bottom - button.bottom, 16);
      expect(clearance, pane.bottom - button.top);
    });

    testWidgets('shows only the content on iOS, where the action belongs in '
        'the navigation bar', (tester) async {
      var clearance = -1.0;
      await tester.pumpWidget(
        _host(TargetPlatform.iOS, onClearance: (value) => clearance = value),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byKey(_contentKey), findsOneWidget);
      expect(clearance, 0);
    });

    testWidgets('keeps the space of a hidden action so content does not '
        'move', (tester) async {
      var clearance = -1.0;
      await tester.pumpWidget(
        _host(
          TargetPlatform.android,
          isActionVisible: false,
          onClearance: (value) => clearance = value,
        ),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(clearance, 72);
    });

    testWidgets('reserves no space without an action', (tester) async {
      var clearance = -1.0;
      await tester.pumpWidget(
        _host(
          TargetPlatform.android,
          hasAction: false,
          onClearance: (value) => clearance = value,
        ),
      );

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(clearance, 0);
    });
  });
}
