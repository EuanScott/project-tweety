import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart'
    show LogEntry;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.model.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';

import 'bloc/logs.bloc.dart';
import 'log_entry_details/log_entry_details.page.dart';
import 'draft_discard_guard.widget.dart';

part 'widgets/logs_empty.widget.dart';
part 'widgets/logs_error.widget.dart';
part 'widgets/logs_list.widget.dart';
part 'widgets/logs_sync_row.widget.dart';

class const Logs({
  final String? selectedLogEntryId,
  final bool isCreating = false,
  super.key,
}) extends StatefulWidget {
  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final GlobalKey<_LogsListState> _logsListKey = GlobalKey<_LogsListState>();

  @override
  void initState() {
    super.initState();
    if (widget.isCreating) {
      context.read<LogsBloc>().add(const LogsCreateStarted());
    }
  }

  /// Logs locations can share one page, so moving to the editor may reuse
  /// this state rather than build a new one.
  @override
  void didUpdateWidget(Logs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCreating && !oldWidget.isCreating) {
      context.read<LogsBloc>().add(const LogsCreateStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LogsDraftDiscardGuard(
      child: BlocListener<LogsBloc, LogsState>(
        listenWhen: (previous, current) =>
            (previous.createdLogEntryId != current.createdLogEntryId &&
                current.createdLogEntryId != null) ||
            (previous.deletedLogEntryId != current.deletedLogEntryId &&
                current.deletedLogEntryId != null),
        listener: (context, state) {
          final createdLogEntryId = state.createdLogEntryId;
          if (createdLogEntryId != null) {
            context.goLogEntryDetails(createdLogEntryId);
            return;
          }
          context.goLogs();
        },
        child: TabReselectHandler(
          tab: AppTab.logs,
          onReselect: _scrollToTop,
          child: Builder(
            builder: (context) {
              final isSplit =
                  PaneLayoutScope.of(context) == PaneLayoutMode.split;
              final selectedLogEntryId = widget.selectedLogEntryId;

              if (!isSplit && widget.isCreating) {
                return PageScaffold(
                  title: l10n.logEntryCreateTitle,
                  kind: PageKind.detail,
                  body: const LogEntryEditor(),
                );
              }

              if (!isSplit && selectedLogEntryId != null) {
                return LogEntryDetailsPage(logEntryId: selectedLogEntryId);
              }

              return PageScaffold(
                title: l10n.logsTab,
                impliesBackAction: false,
                kind: isSplit ? PageKind.displayFixed : PageKind.display,
                primaryAction: ToolBarIconAction(
                  icon: Icons.add,
                  tooltip: l10n.logEntryCreateAction,
                  onPressed: () => _createLogEntry(context),
                ),
                showsPrimaryAction: !widget.isCreating,
                secondaryBody: widget.isCreating
                    ? const LogEntryEditor()
                    : selectedLogEntryId == null
                    ? const LogEntryDetailsEmptyState()
                    : LogEntryDetailsContent(logEntryId: selectedLogEntryId),
                body: _LogsView(
                  listKey: _logsListKey,
                  selectedLogEntryId: selectedLogEntryId,
                  onLogEntrySelected: (logEntryId) =>
                      _selectLogEntry(context, logEntryId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _createLogEntry(BuildContext context) {
    unawaited(
      LogsDraftDiscardGuard.discardThen(context, context.goNewLogEntry),
    );
  }

  void _selectLogEntry(BuildContext context, String logEntryId) {
    unawaited(
      LogsDraftDiscardGuard.discardThen(
        context,
        () => context.goLogEntryDetails(logEntryId),
      ),
    );
  }

  void _scrollToTop() {
    _logsListKey.currentState?.scrollToTop();
  }
}

class const _LogsView({
  required final GlobalKey<_LogsListState> listKey,
  required final String? selectedLogEntryId,
  required final ValueChanged<String> onLogEntrySelected,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: buildWhen and listenWhen for small dedicated UI tasks (snackbar or only conditional rebuilds required)
    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        if (state.isFailure) {
          return _LogsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _LogsList(
          key: listKey,
          items: state.items,
          unsyncedChanges: state.unsyncedChanges,
          selectedLogEntryId: selectedLogEntryId,
          onLogEntrySelected: onLogEntrySelected,
          onRefresh: () => _refreshLogs(context),
          placeholder: _placeholderFor(state),
        );
      },
    );
  }

  /// What fills the page under the sync row when no log entries are showing.
  Widget? _placeholderFor(LogsState state) {
    if (state.hasItems) {
      return null;
    }

    if (state.isInitial || state.isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    return const _LogsEmpty();
  }

  Future<void> _refreshLogs(BuildContext context) async {
    final bloc = context.read<LogsBloc>()..add(const LogsStarted());

    await bloc.stream.firstWhere((state) => !state.isLoading);
  }
}
