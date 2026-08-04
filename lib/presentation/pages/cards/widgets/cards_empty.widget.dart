part of '../cards.page.dart';

class _CardsEmpty extends StatelessWidget {
  const _CardsEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.cardCreateEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.cardCreateEmptyDescription, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton.primary(
              onPressed: () => CardsDraftDiscardGuard.discardThen(
                context,
                () => context.openNewCard(),
              ),
              child: Text(l10n.cardCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}
