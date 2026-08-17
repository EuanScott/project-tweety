import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';

/// Window-level surface classification shared by layout and orientation policy.
///
/// Keeps a single source of truth for the expanded breakpoint and the
/// hinge/fold detection so pane layouts and the orientation policy cannot
/// drift apart.
class DisplayMetrics {
  const DisplayMetrics._();

  /// Shortest side, in logical pixels, at which a surface counts as expanded.
  static const double expandedBreakpoint = 600;

  /// Returns a vertical fold/hinge that splits the supplied media surface.
  static DisplayFeature? verticalDisplayFeatureFor(MediaQueryData mediaQuery) {
    for (final displayFeature in mediaQuery.displayFeatures) {
      final bounds = displayFeature.bounds;
      final isFoldableFeature =
          displayFeature.type == DisplayFeatureType.hinge ||
          displayFeature.type == DisplayFeatureType.fold;
      final splitsVertically =
          bounds.left > 0 &&
          bounds.right < mediaQuery.size.width &&
          bounds.height >= mediaQuery.size.height;
      final isObstructing =
          bounds.shortestSide > 0 ||
          displayFeature.state == DisplayFeatureState.postureHalfOpened ||
          displayFeature.type == DisplayFeatureType.fold;

      if (isFoldableFeature && splitsVertically && isObstructing) {
        return displayFeature;
      }
    }

    return null;
  }

  /// Returns whether the surface is tablet-sized or split by a fold/hinge.
  static bool isExpandedSurface(
    MediaQueryData mediaQuery, {
    double breakpoint = expandedBreakpoint,
  }) {
    return verticalDisplayFeatureFor(mediaQuery) != null ||
        mediaQuery.size.shortestSide >= breakpoint;
  }
}
