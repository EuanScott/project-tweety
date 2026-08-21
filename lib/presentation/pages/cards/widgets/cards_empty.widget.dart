part of '../cards.page.dart';

class const _CardsEmpty() extends StatelessWidget {
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
            Text(l10n.cardCreateEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.cardCreateEmptyDescription, textAlign: .center),
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
