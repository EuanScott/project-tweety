part of '../log_entry_details.page.dart';

class const LogEntryDetailsEmptyState({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _LogEntryDetailsMessage(
      title: l10n.logEntryDetailsEmptyTitle,
      description: l10n.logEntryDetailsEmptyDescription,
    );
  }
}
