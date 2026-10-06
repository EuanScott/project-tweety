import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpTile(WidgetTester tester, TargetPlatform platform) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: AppListTile(
          title: const Text('Text size and bold text'),
          opensOtherApp: true,
          onTap: () {},
        ),
      ),
    ),
  );
}

void main() {
  group('AppListTile that opens another app', () {
    testWidgets('shows a chevron on iOS', (tester) async {
      await _pumpTile(tester, TargetPlatform.iOS);

      expect(find.byType(CupertinoListTileChevron), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsNothing);
    });

    testWidgets('shows an open-in-new icon in primary on Android', (
      tester,
    ) async {
      await _pumpTile(tester, TargetPlatform.android);

      final icon = tester.widget<Icon>(find.byIcon(Icons.open_in_new));
      final context = tester.element(find.byIcon(Icons.open_in_new));

      expect(icon.color, Theme.of(context).colorScheme.primary);
      expect(find.byType(CupertinoListTileChevron), findsNothing);
    });
  });
}
