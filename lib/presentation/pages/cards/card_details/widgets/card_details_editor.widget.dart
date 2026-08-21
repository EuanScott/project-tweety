part of '../card_details.page.dart';

class const _CardDetailsEditor({required final String cardId})
    extends StatefulWidget {
  @override
  State<_CardDetailsEditor> createState() => _CardDetailsEditorState();
}

class _CardDetailsEditorState extends State<_CardDetailsEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final draft = context.read<CardsBloc>().state.draft;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(
            CardsDraftDiscardGuard.discardThen(
              context,
              () => context.read<CardsBloc>().add(const CardsEditCancelled()),
            ),
          );
        }
      },
      child: BlocBuilder<CardsBloc, CardsState>(
        builder: (context, state) {
          final isMissing = state.hasMissingEditFor(widget.cardId);
          final isUpdating = state.isUpdating;
          final disabled = isMissing || isUpdating;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.cardEditTitle,
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.done,
                onChanged: (_) => _onDraftChanged(context),
              ),
              if (state.editError) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.cardEditFailed,
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
                  onPressed: isUpdating
                      ? null
                      : () => context.read<CardsBloc>().add(
                          const CardsEditSubmitted(),
                        ),
                  child: Text(l10n.cardEditSaveAction),
                ),
                const SizedBox(height: 12),
                AppButton.secondary(
                  onPressed: isUpdating
                      ? null
                      : () => CardsDraftDiscardGuard.discardThen(
                          context,
                          () => context.read<CardsBloc>().add(
                            const CardsEditCancelled(),
                          ),
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
