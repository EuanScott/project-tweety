part of '../cards.page.dart';

class _CardEditor extends StatefulWidget {
  const _CardEditor();

  @override
  State<_CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<_CardEditor> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

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
          CardsDraftDiscardGuard.discardThen(context, context.goCards);
        }
      },
      child: BlocBuilder<CardsBloc, CardsState>(
        builder: (context, state) {
          final invalidDraftFields = state.invalidDraftFields;
          final isCreating = state.isCreating;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Text(
                l10n.cardCreateTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _titleController,
                label: l10n.cardCreateTitleLabel,
                enabled: !isCreating,
                errorText: invalidDraftFields.contains(CardDraftField.title)
                    ? l10n.cardCreateTitleRequired
                    : null,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _onDraftChanged(context),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: l10n.cardCreateDescriptionLabel,
                enabled: !isCreating,
                minLines: 4,
                maxLines: 6,
                errorText:
                    invalidDraftFields.contains(CardDraftField.description)
                    ? l10n.cardCreateDescriptionRequired
                    : null,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _onDraftChanged(context),
              ),
              if (state.createError) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.cardCreateFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton.primary(
                onPressed: isCreating
                    ? null
                    : () => context.read<CardsBloc>().add(
                        const CardsCreateSubmitted(),
                      ),
                child: Text(l10n.cardCreateAction),
              ),
              const SizedBox(height: 12),
              AppButton.secondary(
                onPressed: isCreating
                    ? null
                    : () => CardsDraftDiscardGuard.discardThen(
                        context,
                        context.goCards,
                      ),
                child: Text(l10n.cardEditCancelAction),
              ),
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
