part of '../card_details.page.dart';

class const _CardDetailsBody({required final card_model.Card card})
    extends StatefulWidget {
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
