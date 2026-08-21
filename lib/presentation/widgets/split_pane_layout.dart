import 'dart:math' as math;
import 'dart:ui' show DisplayFeature;

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Lays out primary and secondary content beside each other on wide or foldable
/// surfaces.
///
/// The widget owns split-pane mechanics only: breakpoint decisions, foldable
/// display-feature handling, pane sizing, clipping, and primary scroll
/// controller isolation.
/// Creates a split-pane layout for the supplied primary and secondary panes.
class const SplitPaneLayout({
  /// The primary pane, usually a list or master view.
  required final Widget primary,

  /// The secondary pane, usually details for the selected primary item.
  required final Widget secondary,

  /// Optional foldable display feature used to place panes around a hinge/fold.
  required final DisplayFeature? displayFeature,

  /// Constraints from the surrounding page body.
  required final BoxConstraints constraints,

  /// Resolved body padding used to calculate local foldable pane widths.
  required final EdgeInsets resolvedPadding,

  /// The page body's global offset, used to translate display features into the
  /// local coordinate space.
  required final Offset globalOffset,

  /// Optional fixed width for the primary pane on non-foldable layouts.
  final double? primaryWidth,

  /// Horizontal gap on either side of the divider on non-foldable layouts.
  final double paneGap = 16,

  /// Border radius applied to the secondary pane clip.
  final BorderRadius secondaryBorderRadius = _secondaryBorderRadius,
  super.key,
}) extends StatelessWidget {
  static const BorderRadius _secondaryBorderRadius = .only(
    topLeft: .circular(16),
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
  static DisplayFeature? verticalDisplayFeatureFor(MediaQueryData mediaQuery) =>
      DisplayMetrics.verticalDisplayFeatureFor(mediaQuery);

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

class const _PrimaryPane({
  required final double? width,
  required final Widget child,
}) extends StatelessWidget {
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

class const _SecondaryPane({
  required final BorderRadius borderRadius,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController.none(
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
