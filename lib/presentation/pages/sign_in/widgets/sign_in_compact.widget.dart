part of '../sign_in.page.dart';

/// Phones and the folded cover screen: the scene band on top, then the copy,
/// with the sign-in block pinned to the bottom.
class _SignInCompact extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SceneCompactLayout(
      sceneKey: SignInPage.scenePaneKey,
      scene: (context, frame) => _SignInScene(
        compositionSize: frame.compositionSize,
        fadeExtent: frame.fadeExtent,
        fadeAxis: frame.fadeAxis,
        isSplit: false,
        scrollOffset: frame.scrollOffset,
      ),
      body: Column(
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
            style: _subtitleStyle(theme, theme.colorScheme.onSurface),
          ),
        ],
      ),
      footer: const _SignInBlock(),
    );
  }
}
