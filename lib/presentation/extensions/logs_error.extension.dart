import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';

/// Maps each [LogsError] kind to its translated text.
///
/// The switch is exhaustive, so a new error kind fails to compile until it has
/// a translation.
extension LogsErrorExtension on LogsError {
  String message(AppLocalizations l10n) {
    return switch (this) {
      .loadFailed => l10n.logsLoadFailedMessage,
    };
  }
}
