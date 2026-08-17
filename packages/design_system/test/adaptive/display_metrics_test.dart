import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DisplayMetrics.isExpandedSurface', () {
    test('treats a phone in portrait as compact', () {
      expect(
        DisplayMetrics.isExpandedSurface(_mediaQuery(const Size(390, 844))),
        isFalse,
      );
    });

    test('treats a phone in landscape as compact', () {
      expect(
        DisplayMetrics.isExpandedSurface(_mediaQuery(const Size(844, 390))),
        isFalse,
      );
    });

    test('treats a tablet in portrait as expanded', () {
      expect(
        DisplayMetrics.isExpandedSurface(_mediaQuery(const Size(834, 1112))),
        isTrue,
      );
    });

    test('treats an unfolded foldable as expanded', () {
      expect(
        DisplayMetrics.isExpandedSurface(_mediaQuery(const Size(673, 841))),
        isTrue,
      );
    });

    test('treats a half-opened foldable below the breakpoint as expanded', () {
      final mediaQuery = _mediaQuery(
        const Size(580, 800),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(328, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      expect(DisplayMetrics.isExpandedSurface(mediaQuery), isTrue);
    });

    test('does not treat a horizontal fold as expanded', () {
      final mediaQuery = _mediaQuery(
        const Size(580, 800),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(0, 390, 580, 20),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );

      expect(DisplayMetrics.isExpandedSurface(mediaQuery), isFalse);
    });

    test('honours a custom breakpoint', () {
      expect(
        DisplayMetrics.isExpandedSurface(
          _mediaQuery(const Size(673, 841)),
          breakpoint: 700,
        ),
        isFalse,
      );
    });
  });

  group('DisplayMetrics.verticalDisplayFeatureFor', () {
    test('returns null when there are no display features', () {
      expect(
        DisplayMetrics.verticalDisplayFeatureFor(
          _mediaQuery(const Size(580, 800)),
        ),
        isNull,
      );
    });

    test('returns the vertical hinge that splits the surface', () {
      const hinge = DisplayFeature(
        bounds: Rect.fromLTWH(328, 0, 20, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      expect(
        DisplayMetrics.verticalDisplayFeatureFor(
          _mediaQuery(const Size(580, 800), displayFeatures: const [hinge]),
        ),
        hinge,
      );
    });
  });
}

MediaQueryData _mediaQuery(
  Size size, {
  List<DisplayFeature> displayFeatures = const [],
}) {
  return MediaQueryData(size: size, displayFeatures: displayFeatures);
}
