part of '../logs.page.dart';

class const _LogsEmpty() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              l10n.logEntryCreateEmptyTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.logEntryCreateEmptyDescription, textAlign: .center),
            const SizedBox(height: 16),
            AppButton.primary(
              onPressed: () => _createLogEntry(context),
              child: Text(l10n.logEntryCreateAction),
            ),
          ],
        ),
      ),
    );
  }

  void _createLogEntry(BuildContext context) {
    unawaited(
      LogsDraftDiscardGuard.discardThen(context, context.goNewLogEntry),
    );
  }
}
