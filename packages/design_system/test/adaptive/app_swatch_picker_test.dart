import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _tolerance = 1e-6;

const _labels = [
  'Fjord',
  'Fynbos',
  'Kalahari',
  'Lyng',
  'Whin',
  'Douro',
  'Cuillin',
];

final List<AppSwatchOption<String>> _options = [
  for (final label in _labels)
    AppSwatchOption(
      value: label,
      label: label,
      primary: const Color(0xFF0E7474),
      secondary: const Color(0xFF8E3B76),
    ),
];

Future<List<String>> _pumpPicker(
  WidgetTester tester, {
  String value = 'Fjord',
  double width = 600,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  final changes = <String>[];

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: AppSwatchPicker<String>(
              options: _options,
              value: value,
              onChanged: changes.add,
            ),
          ),
        ),
      ),
    ),
  );

  return changes;
}

Finder _tile(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(MergeSemantics),
  );
}

final Finder _ring = find.byWidgetPredicate(
  (widget) =>
      widget is DecoratedBox &&
      widget.decoration is ShapeDecoration &&
      (widget.decoration as ShapeDecoration).shape is CircleBorder &&
      ((widget.decoration as ShapeDecoration).shape as CircleBorder).side !=
          BorderSide.none,
);

final Finder _tick = find.byIcon(Icons.check_rounded);

void main() {
  group('AppSwatchPicker', () {
    testWidgets('shows every option', (tester) async {
      await _pumpPicker(tester);

      for (final label in _labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets(
        'marks only the selected tile with a ring and a tick on '
        '${platform.name}',
        (tester) async {
          await _pumpPicker(tester, value: 'Lyng', platform: platform);

          expect(_ring, findsOneWidget);
          expect(_tick, findsOneWidget);
          expect(
            find.descendant(of: _tile('Lyng'), matching: _ring),
            findsOneWidget,
          );
          expect(
            find.descendant(of: _ring, matching: _tick),
            findsOneWidget,
          );
          expect(
            tester.widget<Text>(find.text('Lyng')).style?.fontWeight,
            FontWeight.w700,
          );
        },
      );

      testWidgets('calls onChanged with the tapped option on '
          '${platform.name}', (tester) async {
        final changes = await _pumpPicker(tester, platform: platform);

        await tester.tap(find.text('Douro'));
        await tester.pump();

        expect(changes, ['Douro']);
      });
    }

    testWidgets('uses Cupertino press feedback on iOS', (tester) async {
      await _pumpPicker(tester, platform: TargetPlatform.iOS);

      expect(find.byType(CupertinoButton), findsNWidgets(_labels.length));
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('announces each tile as a button with its selected state', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpPicker(tester, value: 'Whin');

      expect(
        tester.getSemantics(_tile('Whin')),
        matchesSemantics(
          label: 'Whin',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(_tile('Fjord')),
        matchesSemantics(
          label: 'Fjord',
          isButton: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('gives every tile a tap target at least 44 px tall', (
      tester,
    ) async {
      await _pumpPicker(tester);

      for (final label in _labels) {
        expect(tester.getSize(_tile(label)).height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('does not scroll when all tiles fit', (tester) async {
      await _pumpPicker(tester);

      expect(find.byType(Scrollable), findsNothing);
    });

    testWidgets('scrolls when the tiles do not fit', (tester) async {
      await _pumpPicker(tester, width: 326);

      final position = tester
          .state<ScrollableState>(
            find.byType(Scrollable),
          )
          .position;

      expect(position.axis, Axis.horizontal);
      expect(position.maxScrollExtent, greaterThan(0));
    });

    for (final width in [326.0, 380.0]) {
      testWidgets('shows part of the next tile at $width px', (tester) async {
        await _pumpPicker(tester, width: width);

        final partlyVisible = _labels.where((label) {
          final rect = tester.getRect(_tile(label));
          return rect.left < width && rect.right > width;
        });

        expect(partlyVisible, hasLength(1));
        final rect = tester.getRect(_tile(partlyVisible.single));
        expect(width - rect.left, moreOrLessEquals(rect.width / 2));
      });
    }

    testWidgets('brings a selected tile that starts off-screen into view', (
      tester,
    ) async {
      await _pumpPicker(tester, value: 'Cuillin', width: 326);

      final rect = tester.getRect(_tile('Cuillin'));

      expect(rect.left, greaterThanOrEqualTo(-_tolerance));
      expect(rect.right, lessThanOrEqualTo(326 + _tolerance));
    });

    testWidgets('snaps to a tile edge after a drag', (tester) async {
      await _pumpPicker(tester, width: 326);

      await tester.drag(find.byType(Scrollable), const Offset(-100, 0));
      await tester.pumpAndSettle();

      final firstVisible = _labels
          .map((label) => tester.getRect(_tile(label)).left)
          .where((left) => left >= 0)
          .reduce((a, b) => a < b ? a : b);

      expect(firstVisible, moreOrLessEquals(0, epsilon: 0.5));
    });
  });
}
