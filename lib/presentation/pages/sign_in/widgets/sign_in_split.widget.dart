part of '../sign_in.page.dart';

/// Tablets and open foldables: the scene fills the start pane and the sign-in
/// form sits in the end pane.
///
/// The scene takes 55% of the width, but never leaves the form pane less than
/// [_formMinWidth] and never takes less than half. On a foldable the scene
/// may cross the hinge; the heading and the form never do.
class _SignInSplit extends StatelessWidget {
  const new({super.key});

  static const _formMaxWidth = 400.0;
  static const _formMinWidth = 360.0;

  /// Where the scene, the heading and the form pane sit, measured from the
  /// start edge.
  static ({double sceneWidth, double headingEnd, double formPaneStart}) _panes({
    required double width,
    required Rect? hinge,
    required bool isRtl,
  }) {
    final split = math.max(
      width / 2,
      math.min((0.55 * width).roundToDouble(), width - _formMinWidth),
    );
    final hingeSpan = switch (hinge) {
      null => null,
      final hinge when isRtl => (width - hinge.right, width - hinge.left),
      final hinge => (hinge.left, hinge.right),
    };

    return switch (hingeSpan) {
      null => (sceneWidth: split, headingEnd: split, formPaneStart: split),
      (final start, final end) when split >= end => (
        sceneWidth: split,
        headingEnd: start,
        formPaneStart: split,
      ),
      (final start, final end) => (
        sceneWidth: start,
        headingEnd: start,
        formPaneStart: end,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ink = ScenePalette.of(context).ink;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final hinge = DisplayMetrics.verticalDisplayFeatureFor(
      MediaQuery.of(context),
    )?.bounds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final (:sceneWidth, :headingEnd, :formPaneStart) = _panes(
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
              child: _SignInScene(
                compositionSize: Size(sceneWidth, height),
                fadeExtent: fadeWidth,
                fadeAxis: Axis.horizontal,
                isSplit: true,
              ),
            ),
            PositionedDirectional(
              key: SignInPage.scenePaneKey,
              start: 0,
              top: 0,
              width: headingEnd,
              height: height,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 48,
                  top: 64,
                  end: 48,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 8,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: theme.textTheme.safeHeadlineSmall.copyWith(
                        fontSize: 36,
                        height: 1.12,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        l10n.signInSceneSubtitle,
                        style: _subtitleStyle(theme, ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              key: SignInPage.formPaneKey,
              start: formPaneStart,
              end: 0,
              top: 0,
              height: height,
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
                    constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          l10n.signInSplitTitle,
                          style: theme.textTheme.safeHeadlineSmall.copyWith(
                            fontSize: 24,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.signInSplitSubtitle,
                          style: _subtitleStyle(
                            theme,
                            theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const _SignInBlock(),
                      ],
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
