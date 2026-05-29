import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/widgets/app_bar.dart';

/// A shared page shell that standardises the app scaffold structure.
///
/// This widget owns the common presentation layout for top-level and nested
/// pages:
/// - [Scaffold]
/// - [CustomAppBar]
/// - [SafeArea]
/// - consistent body padding
///
/// Business logic such as BLoC creation, event dispatching, and navigation
/// decisions should stay in the calling page.
class PageScaffold extends StatelessWidget {
  /// Creates a page scaffold with a standard app bar and padded safe body.
  const PageScaffold({
    required this.title,
    required this.body,
    this.secondaryBody,
    this.trailingAction,
    this.floatingActionButton,
    this.prefersLargeCupertinoTitle = false,
    this.allowsLargeCupertinoTitleCollapse = true,
    this.secondaryBreakpoint = 600,
    this.primaryBodyWidth,
    this.paneGap = 16,
    this.bodyPadding = _bodyPadding,
    super.key,
  });

  static const EdgeInsets _bodyPadding = EdgeInsets.symmetric(horizontal: 16);
  static const BorderRadius _secondaryBodyBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
  );

  /// Whether the current surface should render primary and secondary panes.
  ///
  /// Real foldable display features win over the width breakpoint so a device
  /// hinge or fold is respected even when the full window is below the tablet
  /// fallback width.
  static bool usesSplitPaneLayout(
    BuildContext context,
    BoxConstraints constraints, {
    double secondaryBreakpoint = 600,
  }) {
    return _verticalDisplayFeatureFor(MediaQuery.of(context)) != null ||
        constraints.maxWidth >= secondaryBreakpoint;
  }

  /// The title rendered in the shared app bar.
  final String title;

  /// The primary content of the page.
  final Widget body;

  /// Optional secondary content shown beside [body] on wider layouts.
  final Widget? secondaryBody;

  /// The optional typed trailing action rendered in the shared app bar.
  final CustomAppBarAction? trailingAction;

  /// The optional floating action button for the page.
  final Widget? floatingActionButton;

  /// Whether iOS should render a native collapsing large title.
  ///
  /// Material platforms ignore this flag and keep the standard [AppBar].
  final bool prefersLargeCupertinoTitle;

  /// Whether an iOS large title can collapse through scroll gestures.
  ///
  /// Short pages can keep the large-title presentation while disabling the
  /// header-only scroll range that otherwise exists even when content fits.
  final bool allowsLargeCupertinoTitleCollapse;

  /// Width at which [secondaryBody] is shown beside [body].
  final double secondaryBreakpoint;

  /// Optional fixed width for [body] when [secondaryBody] is visible.
  final double? primaryBodyWidth;

  /// Horizontal gap on either side of the divider between body panes.
  final double paneGap;

  /// Padding applied around the safe body area.
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cupertinoBackgroundColor = theme.brightness == Brightness.dark
        ? theme.appBarTheme.backgroundColor
        : null;

    if (AppDesignPlatform.of(context).isCupertino) {
      if (prefersLargeCupertinoTitle) {
        return CupertinoPageScaffold(
          child: NestedScrollView(
            physics: allowsLargeCupertinoTitleCollapse
                ? null
                : const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                CupertinoSliverNavigationBar(
                  backgroundColor: cupertinoBackgroundColor,
                  largeTitle: Text(title),
                  trailing: _cupertinoTrailingAction,
                ),
              ];
            },
            body: SafeArea(
              top: false,
              child: _PageScaffoldBody(scaffold: this),
            ),
          ),
        );
      }

      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: cupertinoBackgroundColor,
          middle: Text(title),
          trailing: _cupertinoTrailingAction,
        ),
        child: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: title, trailingAction: trailingAction),
      body: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget? get _cupertinoTrailingAction {
    final action = trailingAction;
    if (action == null) {
      return null;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: action.onPressed,
      child: Icon(action.icon),
    );
  }
}

class _PageScaffoldBody extends StatefulWidget {
  const _PageScaffoldBody({required this.scaffold});

  final PageScaffold scaffold;

  @override
  State<_PageScaffoldBody> createState() => _PageScaffoldBodyState();
}

class _PageScaffoldBodyState extends State<_PageScaffoldBody> {
  Offset _globalOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    _syncGlobalOffsetAfterLayout();

    final scaffold = widget.scaffold;

    return LayoutBuilder(
      builder: (context, constraints) {
        final secondaryBody = scaffold.secondaryBody;
        final mediaQuery = MediaQuery.of(context);
        final displayFeature = _verticalDisplayFeatureFor(mediaQuery);
        final showSecondary =
            secondaryBody != null &&
            PageScaffold.usesSplitPaneLayout(
              context,
              constraints,
              secondaryBreakpoint: scaffold.secondaryBreakpoint,
            );
        final resolvedPadding = scaffold.bodyPadding.resolve(
          Directionality.of(context),
        );

        return Padding(
          padding: scaffold.bodyPadding,
          child: showSecondary
              ? _SplitPaneBody(
                  scaffold: scaffold,
                  displayFeature: displayFeature,
                  constraints: constraints,
                  resolvedPadding: resolvedPadding,
                  globalOffset: _globalOffset,
                  secondaryBody: secondaryBody,
                )
              : scaffold.body,
        );
      },
    );
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

class _SplitPaneBody extends StatelessWidget {
  const _SplitPaneBody({
    required this.scaffold,
    required this.displayFeature,
    required this.constraints,
    required this.resolvedPadding,
    required this.globalOffset,
    required this.secondaryBody,
  });

  final PageScaffold scaffold;
  final DisplayFeature? displayFeature;
  final BoxConstraints constraints;
  final EdgeInsets resolvedPadding;
  final Offset globalOffset;
  final Widget secondaryBody;

  @override
  Widget build(BuildContext context) {
    final displayFeatureBounds = _localDisplayFeatureBounds;

    if (displayFeatureBounds != null) {
      final primaryWidth = _primaryWidthForDisplayFeature(displayFeatureBounds);

      return Row(
        children: [
          _PrimaryPane(width: primaryWidth, child: scaffold.body),
          SizedBox(
            width: _gapWidthForDisplayFeature(
              displayFeatureBounds,
              primaryWidth,
            ),
          ),
          Expanded(child: _SecondaryPane(child: secondaryBody)),
        ],
      );
    }

    return Row(
      children: [
        _PrimaryPane(width: scaffold.primaryBodyWidth, child: scaffold.body),
        SizedBox(width: scaffold.paneGap),
        const VerticalDivider(width: 1),
        SizedBox(width: scaffold.paneGap),
        Expanded(child: _SecondaryPane(child: secondaryBody)),
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
    double primaryWidth,
  ) {
    return displayFeatureBounds.width
        .clamp(0.0, math.max(0, _availableWidth - primaryWidth))
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
  const _SecondaryPane({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController.none(
      child: ClipRRect(
        borderRadius: PageScaffold._secondaryBodyBorderRadius,
        child: child,
      ),
    );
  }
}

DisplayFeature? _verticalDisplayFeatureFor(MediaQueryData mediaQuery) {
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
