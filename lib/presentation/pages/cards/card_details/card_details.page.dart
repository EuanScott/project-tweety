import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as card_model;
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    show CardDraft, CardDraftField;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';
import 'package:project_tweety/presentation/pages/cards/draft_discard_guard.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

class CardDetailsPage extends StatelessWidget {
  const CardDetailsPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.cardDetailsTitle,
      body: CardDetailsContent(cardId: cardId),
    );
  }
}

class CardDetailsContent extends StatelessWidget {
  const CardDetailsContent({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return _CardDetailsView(cardId: cardId);
  }
}

class _CardDetailsView extends StatelessWidget {
  const _CardDetailsView({required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        final detail = state.detailFor(cardId);

        if (detail.isLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (detail.isFailure) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsLoadFailedTitle,
            description:
                detail.errorMessage ?? l10n.cardDetailsLoadFailedDescription,
          );
        }

        if (detail.isMissing) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsMissingTitle,
            description: l10n.cardDetailsMissingDescription,
          );
        }

        final card = detail.card;
        if (card == null) {
          return _CardDetailsMessage(
            title: l10n.cardDetailsMissingTitle,
            description: l10n.cardDetailsMissingDescription,
          );
        }

        if (state.isEditingCard(cardId)) {
          return _CardDetailsEditor(cardId: cardId);
        }

        return _CardDetailsBody(card: card);
      },
    );
  }
}

class CardDetailsEmptyState extends StatelessWidget {
  const CardDetailsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardDetailsMessage(
      title: l10n.cardDetailsEmptyTitle,
      description: l10n.cardDetailsEmptyDescription,
    );
  }
}

class _CardDetailsBody extends StatefulWidget {
  const _CardDetailsBody({required this.card});

  final card_model.Card card;

  @override
  State<_CardDetailsBody> createState() => _CardDetailsBodyState();
}

class _CardDetailsBodyState extends State<_CardDetailsBody> {
  var _isConfirmationShowing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final card = widget.card;

    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
          final isDeleting = state.isDeletingCard(card.id);
          final hasDeleteError = state.hasDeleteErrorFor(card.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(card.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(card.description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.cardDetailsIdLabel, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              SelectableText(card.id, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 32),
              AppButton.primary(
                onPressed: isDeleting
                    ? null
                    : () => context.read<CardsBloc>().add(
                        CardsEditStarted(card.id),
                      ),
                child: Text(l10n.cardEditAction),
              ),
              const SizedBox(height: 12),
              if (hasDeleteError) ...[
                Text(
                  l10n.cardDeleteFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
                AppButton.destructive(
                  onPressed: isDeleting
                      ? null
                      : () => context.read<CardsBloc>().add(
                          CardsDeleteSubmitted(card.id),
                        ),
                  child: Text(l10n.cardDeleteRetryAction),
                ),
              ] else
                AppButton.destructive(
                  onPressed: isDeleting || _isConfirmationShowing
                      ? null
                      : () => _confirmDelete(context),
                  child: Text(l10n.cardDeleteAction),
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
      title: AppLocalizations.of(context)!.cardDeleteConfirmationTitle,
      content: AppLocalizations.of(context)!.cardDeleteConfirmationDescription,
      cancelLabel: AppLocalizations.of(context)!.cardDeleteCancelAction,
      confirmLabel: AppLocalizations.of(context)!.cardDeleteAction,
      isDestructive: true,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isConfirmationShowing = false);
    if (confirmed) {
      this.context.read<CardsBloc>().add(CardsDeleteSubmitted(widget.card.id));
    }
  }
}

class _CardDetailsEditor extends StatefulWidget {
  const _CardDetailsEditor({required this.cardId});

  final String cardId;

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
          CardsDraftDiscardGuard.discardThen(
            context,
            () => context.read<CardsBloc>().add(const CardsEditCancelled()),
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
              errorText: state.invalidDraftFields.contains(CardDraftField.title)
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
                  state.invalidDraftFields.contains(CardDraftField.description)
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

class _CardDetailsMessage extends StatelessWidget {
  const _CardDetailsMessage({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
