part of '../app_preferences.page.dart';

class _AppPreferencesError extends StatelessWidget {
  const _AppPreferencesError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton.primary(
              onPressed: () {
                unawaited(
                  context.read<AppPreferencesCubit>().loadAppPreferences(),
                );
              },
              child: Text(l10n.appPreferencesRetry),
            ),
          ],
        ),
      ),
    );
  }
}
