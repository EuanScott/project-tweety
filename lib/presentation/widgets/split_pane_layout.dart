import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:material_ui/material_ui.dart';

/// Lays out primary and secondary content beside each other on wide or foldable
/// surfaces.
///
/// The widget owns split-pane mechanics only: breakpoint decisions, foldable
/// display-feature handling, pane sizing, clipping, and primary scroll
/// controller isolation.
class SplitPaneLayout extends StatelessWidget {
  /// Creates a split-pane layout for the supplied primary and secondary panes.
  const SplitPaneLayout({
    required this.primary,
    required this.secondary,
    required this.displayFeature,
    required this.constraints,
    required this.resolvedPadding,
    required this.globalOffset,
    this.primaryWidth,
    this.paneGap = 16,
    this.secondaryBorderRadius = _secondaryBorderRadius,
    super.key,
  });

  static const BorderRadius _secondaryBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
  );

  /// Returns whether a two-pane layout should be used for the current surface.
  static bool shouldUse(
    BuildContext context,
    BoxConstraints constraints, {
    double breakpoint = 600,
  }) {
    return verticalDisplayFeatureFor(MediaQuery.of(context)) != null ||
        constraints.maxWidth >= breakpoint;
  }

  /// Returns a vertical fold/hinge that splits the current media surface.
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

  /// The primary pane, usually a list or master view.
  final Widget primary;

  /// The secondary pane, usually details for the selected primary item.
  final Widget secondary;

  /// Optional foldable display feature used to place panes around a hinge/fold.
  final DisplayFeature? displayFeature;

  /// Constraints from the surrounding page body.
  final BoxConstraints constraints;

  /// Resolved body padding used to calculate local foldable pane widths.
  final EdgeInsets resolvedPadding;

  /// The page body's global offset, used to translate display features into the
  /// local coordinate space.
  final Offset globalOffset;

  /// Optional fixed width for the primary pane on non-foldable layouts.
  final double? primaryWidth;

  /// Horizontal gap on either side of the divider on non-foldable layouts.
  final double paneGap;

  /// Border radius applied to the secondary pane clip.
  final BorderRadius secondaryBorderRadius;

  @override
  Widget build(BuildContext context) {
    final displayFeatureBounds = _localDisplayFeatureBounds;

    if (displayFeatureBounds != null) {
      final resolvedPrimaryWidth = _primaryWidthForDisplayFeature(
        displayFeatureBounds,
      );

      return Row(
        children: [
          _PrimaryPane(width: resolvedPrimaryWidth, child: primary),
          SizedBox(
            width: _gapWidthForDisplayFeature(
              displayFeatureBounds,
              resolvedPrimaryWidth,
            ),
          ),
          Expanded(
            child: _SecondaryPane(
              borderRadius: secondaryBorderRadius,
              child: secondary,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _PrimaryPane(width: primaryWidth, child: primary),
        SizedBox(width: paneGap),
        const VerticalDivider(width: 1),
        SizedBox(width: paneGap),
        Expanded(
          child: _SecondaryPane(
            borderRadius: secondaryBorderRadius,
            child: secondary,
          ),
        ),
      ],
    );
  }

  double _primaryWidthForDisplayFeature(Rect displayFeatureBounds) {
    final availableWidth = _availableWidth;
    return (displayFeatureBounds.left - resolvedPadding.left)
        .clamp(0.0, availableWidth)
        .toDouble();
  }

  double _gapWidthForDisplayFeature(
    Rect displayFeatureBounds,
    double resolvedPrimaryWidth,
  ) {
    return displayFeatureBounds.width
        .clamp(0.0, math.max(0, _availableWidth - resolvedPrimaryWidth))
        .toDouble();
  }

  double get _availableWidth {
    return (constraints.maxWidth - resolvedPadding.horizontal)
        .clamp(0.0, double.infinity)
        .toDouble();
  }

  Rect? get _localDisplayFeatureBounds {
    final displayFeature = this.displayFeature;
    if (displayFeature == null) {
      return null;
    }

    final bounds = displayFeature.bounds.shift(-globalOffset);
    final crossesLocalHeight =
        bounds.top <= 0 && bounds.bottom >= constraints.maxHeight;
    final splitsLocalWidth =
        bounds.left > 0 && bounds.right < constraints.maxWidth;

    return crossesLocalHeight && splitsLocalWidth ? bounds : null;
  }
}

class _PrimaryPane extends StatelessWidget {
  const _PrimaryPane({required this.width, required this.child});

  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = this.width;
    final child = PrimaryScrollController.none(child: this.child);

    if (width == null) {
      return Expanded(child: child);
    }

    return SizedBox(width: width, child: child);
  }
}

class _SecondaryPane extends StatelessWidget {
  const _SecondaryPane({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController.none(
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
