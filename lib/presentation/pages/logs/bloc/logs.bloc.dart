import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

part 'logs.event.dart';
part 'logs.state.dart';
part 'logs.bloc.freezed.dart';

@injectable
class LogsBloc extends Bloc<LogsEvent, LogsState> {
  new(this._logsRepository) : super(const LogsState()) {
    on<LogsStarted>(_onStarted);
    on<LogsCreateStarted>(_onCreateStarted);
    on<LogsDraftChanged>(_onDraftChanged);
    on<LogsCreateSubmitted>(_onCreateSubmitted);
    on<LogsEditStarted>(_onEditStarted);
    on<LogsEditCancelled>(_onEditCancelled);
    on<LogsDraftDiscarded>(_onDraftDiscarded);
    on<LogsEditSubmitted>(_onEditSubmitted);
    on<LogsDeleteSubmitted>(_onDeleteSubmitted);
    on<LogsSyncChanged>(_onSyncChanged);
    on<LogsSyncRequested>(_onSyncRequested, transformer: droppable());
  }

  final LogsRepository _logsRepository;

  void _onSyncChanged(LogsSyncChanged event, Emitter<LogsState> emit) {
    emit(
      state.copyWith(sync: event.sync, unsyncedChanges: event.unsyncedChanges),
    );
  }

  void _onCreateStarted(LogsCreateStarted event, Emitter<LogsState> emit) {
    emit(
      state.copyWith(
        draft: const LogEntryDraft(title: '', description: ''),
        initialDraft: const LogEntryDraft(title: '', description: ''),
        invalidDraftFields: const <LogEntryDraftField>{},
        hasSubmittedCreate: false,
        createStatus: LogsCreateStatus.idle,
        createError: false,
        createdLogEntryId: null,
      ),
    );
  }

  Future<void> _onStarted(LogsStarted event, Emitter<LogsState> emit) async {
    emit(
      state.copyWith(
        status: LogsStatus.loading,
        items: const [],
        errorMessage: null,
      ),
    );

    try {
      final items = await _logsRepository.getLogs();

      emit(
        state.copyWith(
          status: LogsStatus.success,
          items: items,
          errorMessage: null,
        ),
      );
      await _refreshSync(emit);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: LogsStatus.failure,
          items: const [],
          errorMessage: 'Unable to load logs right now.',
        ),
      );
    }
  }

  void _onDraftChanged(LogsDraftChanged event, Emitter<LogsState> emit) {
    final hasSubmitted = state.isEditing
        ? state.hasSubmittedEdit
        : state.hasSubmittedCreate;
    emit(
      state.copyWith(
        draft: event.draft,
        invalidDraftFields: hasSubmitted
            ? event.draft.invalidFields
            : const <LogEntryDraftField>{},
      ),
    );
  }

  void _onEditStarted(LogsEditStarted event, Emitter<LogsState> emit) {
    final logEntry = state.items
        .where((item) => item.id == event.logEntryId)
        .firstOrNull;
    if (logEntry == null || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        draft: LogEntryDraft(
          title: logEntry.title,
          description: logEntry.description,
        ),
        initialDraft: LogEntryDraft(
          title: logEntry.title,
          description: logEntry.description,
        ),
        invalidDraftFields: const <LogEntryDraftField>{},
        editingLogEntryId: logEntry.id,
        hasSubmittedEdit: false,
        editStatus: LogsEditStatus.idle,
        editError: false,
        missingEditLogEntryId: null,
        updatedLogEntryId: null,
      ),
    );
  }

  void _onEditCancelled(LogsEditCancelled event, Emitter<LogsState> emit) {
    if (!state.isEditing || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        editingLogEntryId: null,
        initialDraft: null,
        hasSubmittedEdit: false,
        editStatus: LogsEditStatus.idle,
        editError: false,
        missingEditLogEntryId: null,
      ),
    );
  }

  void _onDraftDiscarded(LogsDraftDiscarded event, Emitter<LogsState> emit) {
    if (state.isCreating || state.isEditing) {
      emit(
        state.copyWith(
          draft: const LogEntryDraft(title: '', description: ''),
          initialDraft: null,
          invalidDraftFields: const <LogEntryDraftField>{},
          hasSubmittedCreate: false,
          createStatus: LogsCreateStatus.idle,
          createError: false,
          editingLogEntryId: null,
          hasSubmittedEdit: false,
          editStatus: LogsEditStatus.idle,
          editError: false,
          missingEditLogEntryId: null,
        ),
      );
    }
  }

  Future<void> _onEditSubmitted(
    LogsEditSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    final logEntryId = state.editingLogEntryId;
    if (logEntryId == null ||
        state.isUpdating ||
        state.hasMissingEditFor(logEntryId)) {
      return;
    }

    final invalidDraftFields = state.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          hasSubmittedEdit: true,
          invalidDraftFields: invalidDraftFields,
          editStatus: LogsEditStatus.idle,
          editError: false,
        ),
      );
      return;
    }

    final initialDraft = state.initialDraft;
    if (initialDraft != null && state.draft == initialDraft) {
      emit(
        state.copyWith(
          editingLogEntryId: null,
          initialDraft: null,
          invalidDraftFields: const <LogEntryDraftField>{},
          hasSubmittedEdit: false,
          editStatus: LogsEditStatus.idle,
          editError: false,
          missingEditLogEntryId: null,
          updatedLogEntryId: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasSubmittedEdit: true,
        invalidDraftFields: const <LogEntryDraftField>{},
        editStatus: LogsEditStatus.updating,
        editError: false,
        missingEditLogEntryId: null,
        updatedLogEntryId: null,
      ),
    );

    try {
      final updatedLogEntry = await _logsRepository.updateLogEntry(
        logEntryId: logEntryId,
        draft: state.draft,
      );
      emit(
        state.copyWith(
          items: state.items
              .map(
                (logEntry) =>
                    logEntry.id == logEntryId ? updatedLogEntry : logEntry,
              )
              .toList(growable: false),
          draft: const LogEntryDraft(title: '', description: ''),
          initialDraft: null,
          invalidDraftFields: const <LogEntryDraftField>{},
          editingLogEntryId: null,
          hasSubmittedEdit: false,
          editStatus: LogsEditStatus.success,
          editError: false,
          updatedLogEntryId: logEntryId,
        ),
      );
      await _refreshSync(emit);
    } on InvalidLogEntryDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          invalidDraftFields: error.invalidFields,
          editStatus: LogsEditStatus.idle,
        ),
      );
    } on LogEntryNotFoundException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          editStatus: LogsEditStatus.notFound,
          editError: false,
          missingEditLogEntryId: error.logEntryId,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(editStatus: LogsEditStatus.failure, editError: true));
    }
  }

  Future<void> _onCreateSubmitted(
    LogsCreateSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    if (state.isCreating) {
      return;
    }

    final invalidDraftFields = state.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          hasSubmittedCreate: true,
          invalidDraftFields: invalidDraftFields,
          createStatus: LogsCreateStatus.idle,
          createError: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasSubmittedCreate: true,
        invalidDraftFields: const <LogEntryDraftField>{},
        createStatus: LogsCreateStatus.creating,
        createError: false,
        createdLogEntryId: null,
      ),
    );

    try {
      final logEntry = await _logsRepository.createLogEntry(state.draft);
      emit(
        state.copyWith(
          items: [logEntry, ...state.items],
          draft: const LogEntryDraft(title: '', description: ''),
          initialDraft: null,
          invalidDraftFields: const <LogEntryDraftField>{},
          hasSubmittedCreate: false,
          createStatus: LogsCreateStatus.success,
          createdLogEntryId: logEntry.id,
        ),
      );
      await _refreshSync(emit);
    } on InvalidLogEntryDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          invalidDraftFields: error.invalidFields,
          createStatus: LogsCreateStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          createStatus: LogsCreateStatus.failure,
          createError: true,
        ),
      );
    }
  }

  Future<void> _onDeleteSubmitted(
    LogsDeleteSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    if (state.isDeleting) {
      return;
    }

    emit(
      state.copyWith(
        deleteStatus: LogsDeleteStatus.deleting,
        deletingLogEntryId: event.logEntryId,
        deleteErrorLogEntryId: null,
        deletedLogEntryId: null,
      ),
    );

    try {
      await _logsRepository.deleteLogEntry(event.logEntryId);
      emit(
        state.copyWith(
          items: state.items
              .where((logEntry) => logEntry.id != event.logEntryId)
              .toList(growable: false),
          deleteStatus: LogsDeleteStatus.success,
          deletingLogEntryId: null,
          deletedLogEntryId: event.logEntryId,
        ),
      );
      await _refreshSync(emit);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          deleteStatus: LogsDeleteStatus.failure,
          deletingLogEntryId: null,
          deleteErrorLogEntryId: event.logEntryId,
        ),
      );
    }
  }

  Future<void> _onSyncRequested(
    LogsSyncRequested event,
    Emitter<LogsState> emit,
  ) async {
    if (state.sync.isBusy) {
      return;
    }

    var changeCount = 0;
    try {
      final result = await _logsRepository.syncLogs(
        onProgress: (savedCount, total) {
          changeCount = total;
          emit(
            state.copyWith(
              sync: LogsSync.syncing(
                savedCount: savedCount,
                changeCount: total,
              ),
            ),
          );
        },
      );
      final summary = await _logsRepository.getSyncSummary();
      final stillPending = summary.pendingChanges.length;
      final outcome = _syncOutcome(result);
      emit(
        state.copyWith(
          // Changes saved during the sync are still pending, so a full
          // success would overstate what reached the Account.
          sync: stillPending > 0 && outcome is LogsSyncSynced
              ? LogsSync.pending(changeCount: stillPending)
              : outcome,
          unsyncedChanges: _unsyncedChanges(summary),
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(sync: LogsSync.failed(changeCount: changeCount)));
    }
  }

  /// Re-reads what is pending after a change is saved. A running sync keeps
  /// its progress; any other state becomes the pending count or the last
  /// sync time.
  Future<void> _refreshSync(Emitter<LogsState> emit) async {
    final LogsSyncSummary summary;
    try {
      summary = await _logsRepository.getSyncSummary();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return;
    }

    final changeCount = summary.pendingChanges.length;
    emit(
      state.copyWith(
        unsyncedChanges: _unsyncedChanges(summary),
        sync: state.sync.isBusy
            ? state.sync
            : changeCount == 0
            ? LogsSync.upToDate(lastSyncedAt: summary.lastSyncedAt)
            : LogsSync.pending(changeCount: changeCount),
      ),
    );
  }

  static LogsSync _syncOutcome(LogsSyncResult result) {
    final LogsSyncResult(:changeCount, :savedCount) = result;

    if (changeCount == 0) {
      return const LogsSync.alreadyUpToDate();
    }
    if (savedCount == changeCount) {
      return LogsSync.synced(changeCount: changeCount);
    }
    if (savedCount > 0) {
      return LogsSync.partial(savedCount: savedCount, changeCount: changeCount);
    }

    return result.onlyNetworkFailures
        ? LogsSync.offline(changeCount: changeCount)
        : LogsSync.failed(changeCount: changeCount);
  }

  /// A deleted log entry has no row to mark, so only created and edited log entries
  /// carry a marker.
  static Map<String, UnsyncedLogEntryChange> _unsyncedChanges(
    LogsSyncSummary summary,
  ) => {
    for (final MapEntry(key: logEntryId, value: change)
        in summary.pendingChanges.entries)
      if (change == PendingLogEntryChange.created)
        logEntryId: UnsyncedLogEntryChange.created
      else if (change == PendingLogEntryChange.updated)
        logEntryId: UnsyncedLogEntryChange.updated,
  };
}
