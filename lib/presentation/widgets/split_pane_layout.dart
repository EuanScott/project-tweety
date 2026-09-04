import 'dart:math' as math;
import 'dart:ui' show DisplayFeature;

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Lays out primary and secondary content beside each other.
///
/// The widget owns split-pane mechanics only: foldable display-feature
/// handling, pane sizing, clipping, and primary scroll controller isolation.
/// Whether a region should be split at all is [PaneLayoutScope]'s decision,
/// not this widget's.
/// Creates a split-pane layout for the supplied primary and secondary panes.
class const SplitPaneLayout({
  /// The primary pane, usually a list or master view.
  required final Widget primary,

  /// The secondary pane, usually details for the selected primary item.
  required final Widget secondary,

  /// Optional fixed width for the primary pane on non-foldable layouts.
  final double? primaryWidth,

  /// Horizontal gap on either side of the divider on non-foldable layouts.
  final double paneGap = 16,

  /// Border radius applied to the secondary pane clip.
  final BorderRadius secondaryBorderRadius = _secondaryBorderRadius,
  super.key,
}) extends StatefulWidget {
  static const BorderRadius _secondaryBorderRadius = .only(
    topLeft: .circular(16),
  );

  @override
  State<SplitPaneLayout> createState() => _SplitPaneLayoutState();
}

class _SplitPaneLayoutState extends State<SplitPaneLayout> {
  /// Where this widget sits on screen, or null until the first frame has been
  /// laid out and measured.
  ///
  /// Display-feature bounds are in screen coordinates, so translating them into
  /// this widget's own space is impossible before this is known. Guessing an
  /// offset would render one frame of panes at visibly wrong widths, so the
  /// plain split is used until the real offset arrives.
  Offset? _globalOffset;

  @override
  Widget build(BuildContext context) {
    _syncGlobalOffsetAfterLayout();

    final displayFeature = DisplayMetrics.verticalDisplayFeatureFor(
      MediaQuery.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounds = _localDisplayFeatureBounds(displayFeature, constraints);

        if (bounds != null) {
          final resolvedPrimaryWidth = _primaryWidthForDisplayFeature(
            bounds,
            constraints,
          );

          return Row(
            children: [
              _PrimaryPane(
                width: resolvedPrimaryWidth,
                gutter: widget.paneGap,
                child: widget.primary,
              ),
              SizedBox(
                width: _gapWidthForDisplayFeature(
                  bounds,
                  resolvedPrimaryWidth,
                  constraints,
                ),
                child: const _PaneDivider(),
              ),
              Expanded(
                child: _SecondaryPane(
                  borderRadius: widget.secondaryBorderRadius,
                  gutter: widget.paneGap,
                  child: widget.secondary,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            _PrimaryPane(
              width: widget.primaryWidth,
              gutter: widget.paneGap,
              child: widget.primary,
            ),
            const _PaneDivider(),
            Expanded(
              child: _SecondaryPane(
                borderRadius: widget.secondaryBorderRadius,
                gutter: widget.paneGap,
                child: widget.secondary,
              ),
            ),
          ],
        );
      },
    );
  }

  double _primaryWidthForDisplayFeature(
    Rect bounds,
    BoxConstraints constraints,
  ) {
    return bounds.left.clamp(0.0, constraints.maxWidth);
  }

  double _gapWidthForDisplayFeature(
    Rect bounds,
    double resolvedPrimaryWidth,
    BoxConstraints constraints,
  ) {
    return bounds.width
        .clamp(0.0, math.max(0, constraints.maxWidth - resolvedPrimaryWidth))
        .toDouble();
  }

  Rect? _localDisplayFeatureBounds(
    DisplayFeature? displayFeature,
    BoxConstraints constraints,
  ) {
    if (displayFeature == null) {
      return null;
    }

    final globalOffset = _globalOffset;
    if (globalOffset == null) {
      return null;
    }

    final bounds = displayFeature.bounds.shift(-globalOffset);
    final crossesLocalHeight =
        bounds.top <= 0 && bounds.bottom >= constraints.maxHeight;
    final splitsLocalWidth =
        bounds.left > 0 && bounds.right < constraints.maxWidth;

    return crossesLocalHeight && splitsLocalWidth ? bounds : null;
  }

  void _syncGlobalOffsetAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final globalOffset = renderObject.localToGlobal(Offset.zero);
      if (globalOffset == _globalOffset) {
        return;
      }

      setState(() {
        _globalOffset = globalOffset;
      });
    });
  }
}

/// A hairline rule separating the panes.
///
/// Inset from the top and bottom so it reads as a separator between two areas
/// rather than a hard edge cutting the whole surface in two.
class const _PaneDivider() extends StatelessWidget {
  static const double _verticalInsetFraction = 0.05;

  /// Softens the theme's foreground into a charcoal rule. `outlineVariant`
  /// resolves to solid black here, which reads as a hard cut rather than a
  /// separator.
  static const double _tint = 0.28;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        heightFactor: 1 - (_verticalInsetFraction * 2),
        child: VerticalDivider(
          width: 1,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: _tint),
        ),
      ),
    );
  }
}

class const _PrimaryPane({
  required final double? width,
  required final double gutter,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = this.width;
    final child = Padding(
      padding: .only(right: gutter),
      child: PrimaryScrollController.none(child: this.child),
    );

    if (width == null) {
      return Expanded(child: child);
    }

    return SizedBox(width: width, child: child);
  }
}

class const _SecondaryPane({
  required final BorderRadius borderRadius,
  required final double gutter,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .only(left: gutter),
      child: PrimaryScrollController.none(
        child: ClipRRect(borderRadius: borderRadius, child: child),
      ),
    );
  }
}
