part of '../sign_in.page.dart';

/// The failure message above the Google button. Screen readers announce it
/// when it appears.
class _SignInError extends StatelessWidget {
  const new({required this.failure, super.key});

  final SignInFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final body = switch (failure) {
      SignInFailure.network => l10n.signInErrorNetwork,
      SignInFailure.other => l10n.signInErrorOther,
    };

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: const .all(.circular(12)),
        ),
        child: Padding(
          padding: const .symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: .start,
            spacing: 12,
            children: [
              Padding(
                padding: const .only(top: 1),
                child: ExcludeSemantics(
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: .center,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: .circle,
                    ),
                    child: Text(
                      '!',
                      style: theme.textTheme.safeBodySmall.copyWith(
                        fontSize: 13,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      l10n.signInErrorTitle,
                      style: theme.textTheme.safeBodyMedium.copyWith(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                    Text(
                      body,
                      style: theme.textTheme.safeBodyMedium.copyWith(
                        fontSize: 14,
                        height: 1.45,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
