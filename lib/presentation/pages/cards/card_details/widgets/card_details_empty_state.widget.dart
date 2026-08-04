part of '../card_details.page.dart';

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
