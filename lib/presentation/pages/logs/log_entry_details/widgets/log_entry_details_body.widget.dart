part of '../log_entry_details.page.dart';

class const _LogEntryDetailsBody({required final LogEntry logEntry})
    extends StatefulWidget {
  @override
  State<_LogEntryDetailsBody> createState() => _LogEntryDetailsBodyState();
}

class _LogEntryDetailsBodyState extends State<_LogEntryDetailsBody> {
  var _isConfirmationShowing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logEntry = widget.logEntry;

    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        final isDeleting = state.isDeletingLogEntry(logEntry.id);
        final hasDeleteError = state.hasDeleteErrorFor(logEntry.id);

        return ListView(
          padding: const .symmetric(vertical: 16),
          children: [
            Text(logEntry.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(logEntry.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.logEntryDetailsIdLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            SelectableText(logEntry.id, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            AppButton.primary(
              onPressed: isDeleting
                  ? null
                  : () => context.read<LogsBloc>().add(
                      LogsEditStarted(logEntry.id),
                    ),
              child: Text(l10n.logEntryEditAction),
            ),
            const SizedBox(height: 12),
            if (hasDeleteError) ...[
              Text(
                l10n.logEntryDeleteFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              AppButton.destructive(
                onPressed: isDeleting
                    ? null
                    : () => context.read<LogsBloc>().add(
                        LogsDeleteSubmitted(logEntry.id),
                      ),
                child: Text(l10n.logEntryDeleteRetryAction),
              ),
            ] else
              AppButton.destructive(
                onPressed: isDeleting || _isConfirmationShowing
                    ? null
                    : () => _confirmDelete(context),
                child: Text(l10n.logEntryDeleteAction),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    setState(() => _isConfirmationShowing = true);
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: AppLocalizations.of(context)!.logEntryDeleteConfirmationTitle,
      content: AppLocalizations.of(context)!
          .logEntryDeleteConfirmationDescription,
      cancelLabel: AppLocalizations.of(context)!.logEntryDeleteCancelAction,
      confirmLabel: AppLocalizations.of(context)!.logEntryDeleteAction,
      isDestructive: true,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isConfirmationShowing = false);
    if (confirmed) {
      this.context.read<LogsBloc>().add(
        LogsDeleteSubmitted(widget.logEntry.id),
      );
    }
  }
}
