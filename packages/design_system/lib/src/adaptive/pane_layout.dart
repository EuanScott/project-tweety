import 'package:material_ui/material_ui.dart';

import 'display_metrics.dart';

/// How a content region presents primary and secondary content.
enum PaneLayoutMode {
  /// One pane at a time; secondary content becomes its own page.
  compact,

  /// Primary and secondary content side by side.
  split,
}

/// Classifies a content region once and publishes the result to everything
/// below it.
///
/// Place this at the top of the region pages are rendered into, so routing and
/// layout read the same answer instead of each measuring its own box and
/// disagreeing.
///
/// The region is measured as callers will experience it: the incoming
/// constraints less the horizontal safe-area insets, because pages render
/// inside a [SafeArea]. A vertical fold or hinge splits the region regardless
/// of width.
///
/// This answers a region-level question. For the window-level question — may
/// the device rotate, should a modal float — use
/// [DisplayMetrics.isExpandedSurface] instead.
class const PaneLayoutScope({
  /// The content region this scope classifies.
  required final Widget child,

  /// Width at or above which the region shows two panes.
  final double breakpoint = DisplayMetrics.expandedBreakpoint,
  super.key,
}) extends StatelessWidget {
  /// The mode of the nearest enclosing [PaneLayoutScope].
  static PaneLayoutMode of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_PaneLayoutModeScope>();

    assert(scope != null, 'No PaneLayoutScope found above this context.');

    return scope!.mode;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final usableWidth =
            constraints.maxWidth - mediaQuery.padding.horizontal;

        final hasVerticalFold =
            DisplayMetrics.verticalDisplayFeatureFor(mediaQuery) != null;

        return _PaneLayoutModeScope(
          mode: hasVerticalFold || usableWidth >= breakpoint
              ? PaneLayoutMode.split
              : PaneLayoutMode.compact,
          child: child,
        );
      },
    );
  }
}

class const _PaneLayoutModeScope({
  required final PaneLayoutMode mode,
  required super.child,
}) extends InheritedWidget {
  @override
  bool updateShouldNotify(_PaneLayoutModeScope oldWidget) =>
      mode != oldWidget.mode;
}
