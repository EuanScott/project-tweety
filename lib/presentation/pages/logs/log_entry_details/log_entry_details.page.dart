import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';
import 'package:project_tweety/presentation/pages/logs/draft_discard_guard.widget.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';

part 'widgets/log_entry_details_body.widget.dart';
part 'widgets/log_entry_details_editor.widget.dart';
part 'widgets/log_entry_details_empty_state.widget.dart';
part 'widgets/log_entry_details_message.widget.dart';

class const LogEntryDetailsPage({required final String logEntryId, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.logEntryDetailsTitle,
      kind: PageKind.detail,
      body: LogEntryDetailsContent(logEntryId: logEntryId),
    );
  }
}

class const LogEntryDetailsContent({
  required final String logEntryId,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _LogEntryDetailsView(logEntryId: logEntryId);
  }
}

class const _LogEntryDetailsView({required final String logEntryId})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        return switch (state.detailFor(logEntryId)) {
          LogsDetailLoading() => const Center(child: AppLoadingIndicator()),
          LogsDetailFailure(:final errorMessage) => _LogEntryDetailsMessage(
            title: l10n.logEntryDetailsLoadFailedTitle,
            description: errorMessage,
          ),
          LogsDetailMissing() => _LogEntryDetailsMessage(
            title: l10n.logEntryDetailsMissingTitle,
            description: l10n.logEntryDetailsMissingDescription,
          ),
          LogsDetailSuccess(:final logEntry) =>
            state.isEditingLogEntry(logEntryId)
                ? LogEntryEditor(logEntryId: logEntryId)
                : _LogEntryDetailsBody(logEntry: logEntry),
        };
      },
    );
  }
}
