part of '../card_details.page.dart';

/// The one form for a Card. It creates a new Card when [cardId] is null and
/// edits that Card otherwise.
class const CardEditor({final String? cardId, super.key})
    extends StatefulWidget {
  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool get _isCreating => widget.cardId == null;

  @override
  void initState() {
    super.initState();
    // A new Card starts empty: its fresh draft may not have reached the bloc
    // yet, so the bloc's draft could still hold an earlier edit.
    final draft = _isCreating
        ? const CardDraft(title: '', description: '')
        : context.read<CardsBloc>().state.draft;
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
    final cardId = widget.cardId;

    return PopScope(
      canPop: !context.select((CardsBloc bloc) => bloc.state.isDraftDirty),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<CardsBloc>().add(const CardsDraftDiscarded());
          return;
        }

        unawaited(
          CardsDraftDiscardGuard.discardThen(context, () => _close(context)),
        );
      },
      child: BlocBuilder<CardsBloc, CardsState>(
        builder: (context, state) {
          final isMissing = cardId != null && state.hasMissingEditFor(cardId);
          final isSaving = _isCreating ? state.isCreating : state.isUpdating;
          final hasSaveError = _isCreating
              ? state.createError
              : state.editError;
          final disabled = isMissing || isSaving;

          return ListView(
            padding: const .symmetric(vertical: 16),
            children: [
              Text(
                _isCreating ? l10n.cardCreateTitle : l10n.cardEditTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: l10n.cardCreateTitleLabel,
                enabled: !disabled,
                errorText:
                    state.invalidDraftFields.contains(CardDraftField.title)
                    ? l10n.cardCreateTitleRequired
                    : null,
                textInputAction: .next,
                onChanged: (_) => _onDraftChanged(context),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: l10n.cardCreateDescriptionLabel,
                enabled: !disabled,
                minLines: 4,
                maxLines: 6,
                errorText:
                    state.invalidDraftFields.contains(
                      CardDraftField.description,
                    )
                    ? l10n.cardCreateDescriptionRequired
                    : null,
                textInputAction: .done,
                onChanged: (_) => _onDraftChanged(context),
              ),
              if (hasSaveError) ...[
                const SizedBox(height: 16),
                Text(
                  _isCreating ? l10n.cardCreateFailed : l10n.cardEditFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (isMissing) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.cardEditNotFound,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  onPressed: context.goCards,
                  child: Text(l10n.cardEditReturnToCardsAction),
                ),
              ] else ...[
                const SizedBox(height: 24),
                AppButton.primary(
                  onPressed: isSaving ? null : () => _save(context),
                  child: Text(
                    _isCreating
                        ? l10n.cardCreateAction
                        : l10n.cardEditSaveAction,
                  ),
                ),
                const SizedBox(height: 12),
                AppButton.secondary(
                  onPressed: isSaving
                      ? null
                      : () => CardsDraftDiscardGuard.discardThen(
                          context,
                          () => _close(context),
                        ),
                  child: Text(l10n.cardEditCancelAction),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _save(BuildContext context) {
    context.read<CardsBloc>().add(
      _isCreating ? const CardsCreateSubmitted() : const CardsEditSubmitted(),
    );
  }

  /// Leaving a new Card returns to the list; leaving an edit returns to the
  /// Card it was editing.
  void _close(BuildContext context) {
    if (_isCreating) {
      context.goCards();
      return;
    }

    context.read<CardsBloc>().add(const CardsEditCancelled());
  }

  void _onDraftChanged(BuildContext context) {
    context.read<CardsBloc>().add(
      CardsDraftChanged(
        CardDraft(
          title: _titleController.text,
          description: _descriptionController.text,
        ),
      ),
    );
  }
}
