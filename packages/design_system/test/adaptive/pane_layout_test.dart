import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PaneLayoutScope', () {
    testWidgets('splits a region wider than the breakpoint', (tester) async {
      final mode = await _modeFor(tester, regionWidth: 700);

      expect(mode, PaneLayoutMode.split);
    });

    testWidgets('stays compact when safe-area insets pull the usable region '
        'below the breakpoint', (tester) async {
      final mode = await _modeFor(
        tester,
        regionWidth: 620,
        padding: const EdgeInsets.only(left: 40, right: 40),
      );

      expect(mode, PaneLayoutMode.compact);
    });

    testWidgets('splits a half-opened foldable below the breakpoint', (
      tester,
    ) async {
      final mode = await _modeFor(
        tester,
        regionWidth: 580,
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(280, 0, 20, 900),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      expect(mode, PaneLayoutMode.split);
    });
  });
}

Future<PaneLayoutMode> _modeFor(
  WidgetTester tester, {
  required double regionWidth,
  EdgeInsets padding = EdgeInsets.zero,
  List<DisplayFeature> displayFeatures = const [],
}) async {
  late PaneLayoutMode mode;

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(regionWidth, 900),
        padding: padding,
        displayFeatures: displayFeatures,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: regionWidth,
            height: 900,
            child: PaneLayoutScope(
              child: Builder(
                builder: (context) {
                  mode = PaneLayoutScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );

  return mode;
}
