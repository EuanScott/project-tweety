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
    final logEntry = widget.logEntry;

    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        final isDeleting = state.isDeletingLogEntry(logEntry.id);
        final hasDeleteError = state.hasDeleteErrorFor(logEntry.id);
        final unsyncedChange = state.unsyncedChanges[logEntry.id];

        return Column(
          crossAxisAlignment: .stretch,
          children: [
            if (PaneLayoutScope.of(context) == PaneLayoutMode.split)
              AppPaneHeader(title: l10n.logEntryDetailsTitle),
            Expanded(
              child: ListView(
                children: [
                  _LogEntryDetailsSections(
                    logEntry: logEntry,
                    unsyncedChange: unsyncedChange,
                  ),
                  if (hasDeleteError)
                    _LogEntryDetailsError(l10n.logEntryDeleteFailed),
                  Padding(
                    padding: const .all(16),
                    child: AppButtonGroup(
                      children: [
                        AppButton.primary(
                          onPressed: isDeleting
                              ? null
                              : () => context.read<LogsBloc>().add(
                                  LogsEditStarted(logEntry.id),
                                ),
                          child: Text(l10n.logEntryEditAction),
                        ),
                        if (hasDeleteError)
                          AppButton.softDestructive(
                            onPressed: isDeleting
                                ? null
                                : () => context.read<LogsBloc>().add(
                                    LogsDeleteSubmitted(logEntry.id),
                                  ),
                            child: Text(l10n.logEntryDeleteRetryAction),
                          )
                        else
                          AppButton.softDestructive(
                            onPressed: isDeleting || _isConfirmationShowing
                                ? null
                                : () => _confirmDelete(context),
                            child: Text(l10n.logEntryDeleteAction),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
