part of '../card_details.page.dart';

class const CardDetailsEmptyState({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardDetailsMessage(
      title: l10n.cardDetailsEmptyTitle,
      description: l10n.cardDetailsEmptyDescription,
    );
  }
}
