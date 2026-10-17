part of '../log_entry_details.page.dart';

/// The one form for a log entry. It creates a new log entry when [logEntryId] is null and
/// edits that log entry otherwise.
class const LogEntryEditor({final String? logEntryId, super.key})
    extends StatefulWidget {
  @override
  State<LogEntryEditor> createState() => _LogEntryEditorState();
}

class _LogEntryEditorState extends State<LogEntryEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool get _isCreating => widget.logEntryId == null;

  @override
  void initState() {
    super.initState();
    // A new log entry starts empty: its fresh draft may not have reached the bloc
    // yet, so the bloc's draft could still hold an earlier edit.
    final draft = _isCreating
        ? const LogEntryDraft(title: '', description: '')
        : context.read<LogsBloc>().state.draft;
    _titleController = TextEditingController(text: draft.title);
    _descriptionController = TextEditingController(text: draft.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logEntryId = widget.logEntryId;

    return PopScope(
      canPop: !context.select((LogsBloc bloc) => bloc.state.isDraftDirty),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<LogsBloc>().add(const LogsDraftDiscarded());
          return;
        }

        unawaited(
          LogsDraftDiscardGuard.discardThen(context, () => _close(context)),
        );
      },
      child: BlocBuilder<LogsBloc, LogsState>(
        builder: (context, state) {
          final isMissing =
              logEntryId != null && state.hasMissingEditFor(logEntryId);
          final isSaving = _isCreating ? state.isCreating : state.isUpdating;
          final hasSaveError = _isCreating
              ? state.createError
              : state.editError;
          final disabled = isMissing || isSaving;

          return ListView(
            padding: const .symmetric(vertical: 16),
            children: [
              Text(
                _isCreating ? l10n.logEntryCreateTitle : l10n.logEntryEditTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: l10n.logEntryCreateTitleLabel,
                enabled: !disabled,
                errorText:
                    state.invalidDraftFields.contains(LogEntryDraftField.title)
                    ? l10n.logEntryCreateTitleRequired
                    : null,
                textInputAction: .next,
                onChanged: (_) => _onDraftChanged(context),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: l10n.logEntryCreateDescriptionLabel,
                enabled: !disabled,
                minLines: 4,
                maxLines: 6,
                errorText:
                    state.invalidDraftFields.contains(
                      LogEntryDraftField.description,
                    )
                    ? l10n.logEntryCreateDescriptionRequired
                    : null,
                textInputAction: .done,
                onChanged: (_) => _onDraftChanged(context),
              ),
              if (hasSaveError) ...[
                const SizedBox(height: 16),
                Text(
                  _isCreating
                      ? l10n.logEntryCreateFailed
                      : l10n.logEntryEditFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (isMissing) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.logEntryEditNotFound,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  onPressed: context.goLogs,
                  child: Text(l10n.logEntryEditReturnToLogsAction),
                ),
              ] else ...[
                const SizedBox(height: 24),
                AppButton.primary(
                  onPressed: isSaving ? null : () => _save(context),
                  child: Text(
                    _isCreating
                        ? l10n.logEntryCreateAction
                        : l10n.logEntryEditSaveAction,
                  ),
                ),
                const SizedBox(height: 12),
                AppButton.secondary(
                  onPressed: isSaving
                      ? null
                      : () => LogsDraftDiscardGuard.discardThen(
                          context,
                          () => _close(context),
                        ),
                  child: Text(l10n.logEntryEditCancelAction),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _save(BuildContext context) {
    context.read<LogsBloc>().add(
      _isCreating ? const LogsCreateSubmitted() : const LogsEditSubmitted(),
    );
  }

  /// Leaving a new log entry returns to the list; leaving an edit returns to the
  /// Log entry it was editing.
  void _close(BuildContext context) {
    if (_isCreating) {
      context.goLogs();
      return;
    }

    context.read<LogsBloc>().add(const LogsEditCancelled());
  }

  void _onDraftChanged(BuildContext context) {
    context.read<LogsBloc>().add(
      LogsDraftChanged(
        LogEntryDraft(
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      ),
    );
  }
}
