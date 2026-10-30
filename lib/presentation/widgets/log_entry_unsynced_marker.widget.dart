import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';

/// Marks a log entry whose change has not reached the Account yet.
class const LogEntryUnsyncedMarker({
  required final UnsyncedLogEntryChange change,
  super.key,
}) extends StatelessWidget {
  static const double _dotSize = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = theme.colorScheme.secondary;

    return Row(
      mainAxisSize: .min,
      spacing: 4,
      children: [
        Icon(Icons.circle, size: _dotSize, color: color),
        Text(switch (change) {
          UnsyncedLogEntryChange.created => l10n.logsUnsyncedCreated,
          UnsyncedLogEntryChange.updated => l10n.logsUnsyncedUpdated,
        }, style: theme.textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}
