part of '../log_entry_details.page.dart';

/// The log entry and its ID: inset grouped sections on iOS, one card split
/// by a soft rule on Android.
class const _LogEntryDetailsSections({
  required final LogEntry logEntry,
  required final UnsyncedLogEntryChange? unsyncedChange,
}) extends StatelessWidget {
  static const EdgeInsetsGeometry _cardMargin = .all(16);
  static const EdgeInsetsGeometry _cardSectionPadding = .all(16);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unsyncedChange = this.unsyncedChange;

    final entry = Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Flexible(
              child: Text(logEntry.title, style: theme.textTheme.titleLarge),
            ),
            if (unsyncedChange != null)
              LogEntryUnsyncedMarker(change: unsyncedChange),
          ],
        ),
        Text(logEntry.description, style: theme.textTheme.bodyLarge),
      ],
    );
    final id = SelectableText(logEntry.id, style: theme.textTheme.bodyMedium);

    if (AppDesignPlatform.of(context).isCupertino) {
      return Column(
        crossAxisAlignment: .stretch,
        children: [
          AppListSection(children: [AppListSectionContent(child: entry)]),
          AppListSection(
            header: l10n.logEntryDetailsIdLabel,
            children: [AppListSectionContent(child: id)],
          ),
        ],
      );
    }

    return Card(
      margin: _cardMargin,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Padding(padding: _cardSectionPadding, child: entry),
          const Divider(height: 1),
          Padding(
            padding: _cardSectionPadding,
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(
                  l10n.logEntryDetailsIdLabel,
                  style: theme.textTheme.labelLarge,
                ),
                id,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
