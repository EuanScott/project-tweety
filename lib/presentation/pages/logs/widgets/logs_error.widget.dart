part of '../logs.page.dart';

class const _LogsError({required final LogsError error})
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
            Text(error.message(l10n), textAlign: .center),
            const SizedBox(height: 12),
            AppButton.primary(
              onPressed: () {
                context.read<LogsBloc>().add(const LogsStarted());
              },
              child: Text(l10n.commonRetryAction),
            ),
          ],
        ),
      ),
    );
  }
}
