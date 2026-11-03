part of '../sign_in.page.dart';

/// Tablets and open foldables: the scene fills the start pane, with the app
/// title over its sky, and the sign-in form sits in the end pane.
class _SignInSplit extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ink = ScenePalette.of(context).ink;

    return SceneSplitLayout(
      scene: (context, frame) => _SignInScene(
        compositionSize: frame.compositionSize,
        fadeExtent: frame.fadeExtent,
        fadeAxis: frame.fadeAxis,
        isSplit: true,
      ),
      sceneOverlayKey: SignInPage.scenePaneKey,
      sceneOverlay: Padding(
        padding: const EdgeInsetsDirectional.only(start: 48, top: 64, end: 48),
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
      contentKey: SignInPage.formPaneKey,
      content: Column(
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
            style: _subtitleStyle(theme, theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 32),
          const _SignInBlock(),
        ],
      ),
    );
  }
}
