part of '../app_preferences.page.dart';

class const _AppPreferencesError({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(message, textAlign: .center),
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
