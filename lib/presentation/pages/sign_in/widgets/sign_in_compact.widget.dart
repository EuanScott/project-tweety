part of '../sign_in.page.dart';

/// Phones and the folded cover screen: the scene band on top, then the copy,
/// with the sign-in block pinned to the bottom.
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
    final sceneHeight = (0.42 * screen.height).roundToDouble();
    final fadeHeight = (0.10 * screen.height).roundToDouble();
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
class const _SignInSceneHeaderDelegate({
  required final double width,
  required final double sceneHeight,
  required final double fadeHeight,
}) extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => sceneHeight + fadeHeight;

  @override
  double get maxExtent => sceneHeight + fadeHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return _SignInScene(
      key: SignInPage.scenePaneKey,
      compositionSize: Size(width, sceneHeight),
      fadeExtent: fadeHeight,
      fadeAxis: Axis.vertical,
      isSplit: false,
      scrollOffset: shrinkOffset,
    );
  }

  @override
  bool shouldRebuild(_SignInSceneHeaderDelegate oldDelegate) =>
      oldDelegate.width != width ||
      oldDelegate.sceneHeight != sceneHeight ||
      oldDelegate.fadeHeight != fadeHeight;
}
