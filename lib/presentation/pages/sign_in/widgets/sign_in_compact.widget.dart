part of '../sign_in.page.dart';

/// Phones and the folded cover screen: the scene band on top, then the copy,
/// with the sign-in block pinned to the bottom. Below the status bar, the scene
/// and its fade take 60% of the height and the content takes the rest.
///
/// When the content does not fit, the scene scrolls away while the sign-in
/// block stays reachable. When it fits, nothing scrolls.
class _SignInCompact extends StatelessWidget {
  const new({super.key});

  static const _blockFadeHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screen = MediaQuery.sizeOf(context);
    final sidePadding = screen.width < 360 ? 20.0 : 24.0;
    final topInset = MediaQuery.paddingOf(context).top;
    final usableHeight = screen.height - topInset;
    final sceneHeight = (0.50 * usableHeight).roundToDouble();
    final fadeHeight = (0.10 * usableHeight).roundToDouble();
    final background = theme.scaffoldBackgroundColor;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _SignInSceneHeaderDelegate(
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
                      _blockFadeHeight,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        spacing: 8,
                        children: [
                          Text(
                            l10n.appTitle,
                            textAlign: .center,
                            style: theme.textTheme.safeHeadlineSmall.copyWith(
                              fontSize: 28,
                              height: 1.18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            l10n.signInCompactSubtitle,
                            textAlign: .center,
                            style: _subtitleStyle(
                              theme,
                              theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _blockFadeHeight,
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
            child: const _SignInBlock(),
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
class const _SignInSceneHeaderDelegate({
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
          child: _SignInScene(
            key: SignInPage.scenePaneKey,
            compositionSize: Size(width, sceneHeight),
            fadeExtent: fadeHeight,
            fadeAxis: Axis.vertical,
            isSplit: false,
            scrollOffset: shrinkOffset,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_SignInSceneHeaderDelegate oldDelegate) =>
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
