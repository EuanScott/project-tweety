import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/split_pane_layout.dart';

void main() {
  group('SplitPaneLayout', () {
    testWidgets('separates the panes with a divider when there is no fold', (
      tester,
    ) async {
      await _pumpLayout(tester, size: const Size(900, 600));

      expect(find.byKey(_primaryKey), findsOneWidget);
      expect(find.byKey(_secondaryKey), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('places the panes either side of a vertical hinge', (
      tester,
    ) async {
      await _pumpLayout(
        tester,
        size: const Size(500, 800),
        mediaSize: const Size(580, 800),
        layoutOffset: const Offset(80, 0),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(328, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      // 248pt pane, less the 16pt gutter that keeps content off the divider.
      expect(tester.getSize(find.byKey(_primaryKey)).width, 232);
      expect(tester.getTopLeft(find.byKey(_secondaryKey)).dx, 364);
    });

    testWidgets('keeps pane content clear of the divider', (tester) async {
      await _pumpLayout(tester, size: const Size(900, 600));

      final dividerBounds = tester.getRect(find.byType(VerticalDivider));

      expect(
        dividerBounds.left - tester.getRect(find.byKey(_primaryKey)).right,
        16,
      );
      expect(
        tester.getRect(find.byKey(_secondaryKey)).left - dividerBounds.right,
        16,
      );
    });

    testWidgets('draws a divider between the panes, inset from top and bottom', (
      tester,
    ) async {
      await _pumpLayout(tester, size: const Size(900, 600));

      final divider = find.byType(VerticalDivider);

      expect(divider, findsOneWidget);
      expect(
        tester.getSize(divider).height,
        tester.getSize(find.byKey(_primaryKey)).height * 0.9,
      );
    });

    testWidgets('draws the divider beside a hinge too', (tester) async {
      await _pumpLayout(
        tester,
        size: const Size(500, 800),
        mediaSize: const Size(580, 800),
        layoutOffset: const Offset(80, 0),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(328, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(
        tester.getSize(find.byType(VerticalDivider)).height,
        tester.getSize(find.byKey(_primaryKey)).height * 0.9,
      );
    });

    testWidgets('does not place panes against a hinge before it knows where '
        'it sits on screen', (tester) async {
      await _pumpLayout(
        tester,
        size: const Size(500, 800),
        mediaSize: const Size(580, 800),
        layoutOffset: const Offset(80, 0),
        settle: false,
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(328, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      expect(
        tester.getSize(find.byKey(_primaryKey)).width,
        isNot(232),
        reason: 'the first frame must use the plain split, not a hinge '
            'position derived from an unmeasured screen offset',
      );

      await tester.pumpAndSettle();

      expect(tester.getSize(find.byKey(_primaryKey)).width, 232);
    });

    testWidgets('splits the region evenly when no primary width is given', (
      tester,
    ) async {
      await _pumpLayout(tester, size: const Size(900, 600));

      expect(
        tester.getSize(find.byKey(_primaryKey)).width,
        tester.getSize(find.byKey(_secondaryKey)).width,
      );
    });

    testWidgets('honours a fixed primary width', (tester) async {
      await _pumpLayout(
        tester,
        size: const Size(900, 600),
        primaryWidth: 240,
      );

      expect(tester.getSize(find.byKey(_primaryKey)).width, 224);
    });
  });
}

const ValueKey<String> _primaryKey = ValueKey('primary');
const ValueKey<String> _secondaryKey = ValueKey('secondary');

Future<void> _pumpLayout(
  WidgetTester tester, {
  required Size size,
  Size? mediaSize,
  Offset layoutOffset = Offset.zero,
  double? primaryWidth,
  List<DisplayFeature> displayFeatures = const [],
  bool settle = true,
}) async {
  final resolvedMediaSize = mediaSize ?? size;

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: resolvedMediaSize,
          displayFeatures: displayFeatures,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: layoutOffset.dx,
            top: layoutOffset.dy,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(
              size: size,
              child: SplitPaneLayout(
                primaryWidth: primaryWidth,
                primary: const SizedBox.expand(key: _primaryKey),
                secondary: const SizedBox.expand(key: _secondaryKey),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  }
}
