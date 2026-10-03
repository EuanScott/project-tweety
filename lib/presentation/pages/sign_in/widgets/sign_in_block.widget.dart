part of '../sign_in.page.dart';

/// The error message (only after a failure), the Google button and the
/// footnote. Pressing the button again after a failure is the retry.
class _SignInBlock extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SignInCubit, SignInAttemptState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            if (state case SignInAttemptFailed(:final failure))
              _SignInError(key: SignInPage.errorKey, failure: failure),
            AppGoogleSignInButton(
              label: l10n.signInGoogleButton,
              loadingLabel: l10n.signInGoogleButtonInProgress,
              loading: state is SignInAttemptInProgress,
              onPressed: () =>
                  unawaited(context.read<SignInCubit>().signInRequested()),
            ),
            Text(
              l10n.signInFootnote,
              textAlign: .center,
              style: theme.textTheme.safeBodySmall.copyWith(
                fontSize: 12,
                height: 1.4,
                color: theme.colorScheme.onSurface.withValues(
                  alpha: isDark ? 0.7 : 0.6,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The 16 px subtitle style shared by the compact and split layouts.
TextStyle _subtitleStyle(ThemeData theme, Color color) {
  return theme.textTheme.safeBodyLarge.copyWith(
    fontSize: 16,
    height: 1.45,
    color: color,
  );
}
