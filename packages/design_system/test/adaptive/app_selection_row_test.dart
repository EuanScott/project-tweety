import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _options = [
  AppPickerOption<String?>(value: null, label: 'System default'),
  AppPickerOption<String?>(value: 'en', label: 'English'),
  AppPickerOption<String?>(value: 'he', label: 'עברית'),
];

Future<List<String?>> _pumpRow(
  WidgetTester tester, {
  required TargetPlatform platform,
  String? value = 'en',
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final changes = <String?>[];

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) =>
          Directionality(textDirection: textDirection, child: child!),
      home: Scaffold(
        body: AppSelectionRow<String?>(
          title: 'Language',
          value: value,
          options: _options,
          onChanged: changes.add,
        ),
      ),
    ),
  );

  return changes;
}

void main() {
  group('AppSelectionRow on iOS', () {
    testWidgets('shows the selected label on the right with a chevron', (
      tester,
    ) async {
      await _pumpRow(tester, platform: TargetPlatform.iOS);

      expect(find.byType(CupertinoListTile), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.byType(CupertinoListTileChevron), findsOneWidget);
      expect(
        tester.getCenter(find.text('English')).dx,
        greaterThan(tester.getCenter(find.text('Language')).dx),
      );
    });

    testWidgets('pushes a checkmark list and returns the tapped option', (
      tester,
    ) async {
      final changes = await _pumpRow(tester, platform: TargetPlatform.iOS);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.text('System default'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(CupertinoListTile, 'English'),
          matching: find.byIcon(CupertinoIcons.check_mark),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('System default'));
      await tester.pumpAndSettle();

      expect(changes, [null]);
      expect(find.byType(CupertinoPageScaffold), findsNothing);
    });

    testWidgets('does not report a change when the list is dismissed', (
      tester,
    ) async {
      final changes = await _pumpRow(tester, platform: TargetPlatform.iOS);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      expect(changes, isEmpty);
    });

    testWidgets('flips the value and chevron in right-to-left', (
      tester,
    ) async {
      await _pumpRow(
        tester,
        platform: TargetPlatform.iOS,
        textDirection: TextDirection.rtl,
      );

      final titleX = tester.getCenter(find.text('Language')).dx;
      final valueX = tester.getCenter(find.text('English')).dx;
      final chevronX = tester
          .getCenter(find.byType(CupertinoListTileChevron))
          .dx;

      expect(valueX, lessThan(titleX));
      expect(chevronX, lessThan(valueX));
    });
  });

  group('AppSelectionRow on Android', () {
    testWidgets('shows the selected label under the title, no chevron', (
      tester,
    ) async {
      await _pumpRow(tester, platform: TargetPlatform.android);

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(CupertinoListTileChevron), findsNothing);
      expect(
        tester.getTopLeft(find.text('English')).dy,
        greaterThan(tester.getTopLeft(find.text('Language')).dy),
      );
    });

    testWidgets('opens a radio dialog and returns the tapped option', (
      tester,
    ) async {
      final changes = await _pumpRow(tester, platform: TargetPlatform.android);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(RadioListTile<int>), findsNWidgets(_options.length));

      await tester.tap(find.text('עברית'));
      await tester.pumpAndSettle();

      expect(changes, ['he']);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('closes the dialog with no change on the selected option', (
      tester,
    ) async {
      final changes = await _pumpRow(tester, platform: TargetPlatform.android);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('flips the title and value in right-to-left', (tester) async {
      await _pumpRow(
        tester,
        platform: TargetPlatform.android,
        textDirection: TextDirection.rtl,
      );

      final rowCentre = tester.getCenter(find.byType(ListTile)).dx;
      final titleRight = tester.getTopRight(find.text('Language')).dx;

      expect(titleRight, greaterThan(rowCentre));
      expect(tester.getTopRight(find.text('English')).dx, titleRight);
    });
  });
}
