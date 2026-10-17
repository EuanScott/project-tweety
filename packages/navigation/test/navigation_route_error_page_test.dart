import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:navigation/navigation.dart';

Future<void> _pumpErrorPage(
  WidgetTester tester, {
  required TargetPlatform platform,
  VoidCallback? onActionPressed,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: NavigationRouteErrorPage(
        title: 'Page not found',
        description: 'This page does not exist.',
        actionLabel: 'Go home',
        onActionPressed: onActionPressed ?? () {},
      ),
    ),
  );
}

void main() {
  group('NavigationRouteErrorPage', () {
    testWidgets('puts the title in a Cupertino navigation bar on iOS', (
      tester,
    ) async {
      await _pumpErrorPage(tester, platform: TargetPlatform.iOS);

      expect(
        find.descendant(
          of: find.byType(CupertinoNavigationBar),
          matching: find.text('Page not found'),
        ),
        findsOneWidget,
      );
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('puts the title in a Material app bar on Android', (
      tester,
    ) async {
      await _pumpErrorPage(tester, platform: TargetPlatform.android);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Page not found'),
        ),
        findsOneWidget,
      );
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('runs the action on ${platform.name}', (tester) async {
        var pressed = false;
        await _pumpErrorPage(
          tester,
          platform: platform,
          onActionPressed: () => pressed = true,
        );

        await tester.tap(find.text('Go home'));

        expect(pressed, isTrue);
      });
    }
  });
}
