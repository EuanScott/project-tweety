import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/scene_layout/scene_frame.model.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

/// Builds a scene for the frame a scene layout hands it. The scene fills the
/// composition box plus the fade.
typedef SceneFrameBuilder = Widget Function(
  BuildContext context,
  SceneFrame frame,
);

/// Phones and the folded cover screen: the scene band on top, then [body],
/// with [footer] pinned to the bottom. Below the status bar, the scene and its
/// fade take 60% of the height and the rest is for the content.
///
/// When the content does not fit, the scene scrolls away while [footer] stays
/// reachable. When it fits, nothing scrolls.
class const SceneCompactLayout({
  required final SceneFrameBuilder scene,

  /// Centred below the scene, for a heading and a line of copy.
  required final Widget body,

  /// Pinned 40 px above the bottom, for the page's action.
  required final Widget footer,
  final Key? sceneKey,
  super.key,
}) extends StatelessWidget {
  static const _footerFadeHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final sidePadding = screen.width < 360 ? 20.0 : 24.0;
    final topInset = MediaQuery.paddingOf(context).top;
    final usableHeight = screen.height - topInset;
    final sceneHeight = (0.50 * usableHeight).roundToDouble();
    final fadeHeight = (0.10 * usableHeight).roundToDouble();
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _SceneHeaderDelegate(
                      scene: scene,
                      sceneKey: sceneKey,
                      width: screen.width,
                      topInset: topInset,
                      sceneHeight: sceneHeight,
                      fadeHeight: fadeHeight,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      8,
                      sidePadding,
                      _footerFadeHeight,
                    ),
                    sliver: SliverToBoxAdapter(child: body),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _footerFadeHeight,
                child: SceneFade(
                  background: background,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 40),
            child: footer,
          ),
        ),
      ],
    );
  }
}

/// Hands the scroll offset to the scene so each layer can move at its own
/// speed while the band scrolls away.
///
/// The scene starts below the status bar. Sky colour fills behind the status
/// bar and behind the scene, so no gap shows above the scene or where a
/// slower layer lags while the band scrolls.
class const _SceneHeaderDelegate({
  required final SceneFrameBuilder scene,
  required final Key? sceneKey,
  required final double width,
  required final double topInset,
  required final double sceneHeight,
  required final double fadeHeight,
}) extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => topInset + sceneHeight + fadeHeight;

  @override
  double get maxExtent => topInset + sceneHeight + fadeHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: topInset + sceneHeight,
          child: const _SkyFill(),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: topInset,
          child: KeyedSubtree(
            key: sceneKey,
            child: scene(
              context,
              SceneFrame(
                compositionSize: Size(width, sceneHeight),
                fadeExtent: fadeHeight,
                fadeAxis: Axis.vertical,
                scrollOffset: shrinkOffset,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_SceneHeaderDelegate oldDelegate) =>
      !identical(oldDelegate.scene, scene) ||
      oldDelegate.sceneKey != sceneKey ||
      oldDelegate.width != width ||
      oldDelegate.topInset != topInset ||
      oldDelegate.sceneHeight != sceneHeight ||
      oldDelegate.fadeHeight != fadeHeight;
}

/// Sky colour behind the status bar and the scene.
///
/// It reads the palette in its own build. A theme change does not rebuild the
/// header delegate's content when the page rebuilds in the same frame, so a
/// colour read in the delegate's build would stay at the old theme.
class const _SkyFill() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: ScenePalette.of(context).sky);
  }
}

/// Tablets and open foldables: the scene fills the start pane and [content]
/// sits in the end pane, vertically centred.
///
/// The scene takes 55% of the width, but never leaves the content pane less
/// than [_contentMinWidth] and never takes less than half. On a foldable the
/// scene may cross the hinge; [sceneOverlay] and [content] never do.
class const SceneSplitLayout({
  required final SceneFrameBuilder scene,

  /// In a column at most 400 px wide, past the scene's fade.
  required final Widget content,

  /// Drawn over the scene's pane, which ends at the hinge, if any.
  final Widget? sceneOverlay,
  final Key? sceneOverlayKey,

  /// Marks the whole content pane, not only [content].
  final Key? contentKey,
  super.key,
}) extends StatelessWidget {
  static const _contentMaxWidth = 400.0;
  static const _contentMinWidth = 360.0;

  /// Where the scene, the overlay and the content pane sit, measured from the
  /// start edge.
  static ({double sceneWidth, double overlayEnd, double contentStart}) _panes({
    required double width,
    required Rect? hinge,
    required bool isRtl,
  }) {
    final split = math.max(
      width / 2,
      math.min((0.55 * width).roundToDouble(), width - _contentMinWidth),
    );
    final hingeSpan = switch (hinge) {
      null => null,
      final hinge when isRtl => (width - hinge.right, width - hinge.left),
      final hinge => (hinge.left, hinge.right),
    };

    return switch (hingeSpan) {
      null => (sceneWidth: split, overlayEnd: split, contentStart: split),
      (final start, final end) when split >= end => (
        sceneWidth: split,
        overlayEnd: start,
        contentStart: split,
      ),
      (final start, final end) => (
        sceneWidth: start,
        overlayEnd: start,
        contentStart: end,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final hinge = DisplayMetrics.verticalDisplayFeatureFor(
      MediaQuery.of(context),
    )?.bounds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final (:sceneWidth, :overlayEnd, :contentStart) = _panes(
          width: width,
          hinge: hinge,
          isRtl: isRtl,
        );
        final fadeWidth = math.min<double>(96, (0.08 * width).roundToDouble());

        return Stack(
          children: [
            PositionedDirectional(
              start: 0,
              top: 0,
              width: sceneWidth + fadeWidth,
              height: height,
              child: scene(
                context,
                SceneFrame(
                  compositionSize: Size(sceneWidth, height),
                  fadeExtent: fadeWidth,
                  fadeAxis: Axis.horizontal,
                ),
              ),
            ),
            if (sceneOverlay case final overlay?)
              PositionedDirectional(
                start: 0,
                top: 0,
                width: overlayEnd,
                height: height,
                child: KeyedSubtree(key: sceneOverlayKey, child: overlay),
              ),
            PositionedDirectional(
              start: contentStart,
              end: 0,
              top: 0,
              height: height,
              child: KeyedSubtree(
                key: contentKey,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.only(
                      start: 48 + fadeWidth,
                      top: 64,
                      end: 48,
                      bottom: 64,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _contentMaxWidth,
                      ),
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
