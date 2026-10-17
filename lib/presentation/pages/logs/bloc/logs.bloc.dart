import 'dart:async';

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
    on<LogsDownloadProgressed>(
      _onDownloadProgressed,
      transformer: sequential(),
    );
    _downloadSubscription = _logsRepository.downloadProgress.listen(
      (progress) => add(LogsDownloadProgressed(progress)),
    );
  }

  final LogsRepository _logsRepository;
  late final StreamSubscription<LogsDownloadProgress> _downloadSubscription;

  @override
  Future<void> close() async {
    await _downloadSubscription.cancel();
    await super.close();
  }

  /// Downloaded log entries join the list in one update, when the download
  /// ends. A download that added nothing leaves the list alone and shows
  /// nothing ([ADR-0008](../../../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)).
  Future<void> _onDownloadProgressed(
    LogsDownloadProgressed event,
    Emitter<LogsState> emit,
  ) async {
    switch (event.progress) {
      case LogsDownloadAdding() when state.sync is LogsSyncWaiting:
        break;
      case LogsDownloadAdding(:final logEntryCount):
        emit(
          state.copyWith(
            sync: LogsSync.downloading(logEntryCount: logEntryCount),
          ),
        );
      case LogsDownloadFinished(addedCount: 0):
        await _refreshSync(emit, endsDownload: true);
      case LogsDownloadFinished(:final addedCount):
        try {
          final items = await _logsRepository.getLogs();
          final summary = await _logsRepository.getSyncSummary();
          emit(
            state.copyWith(
              load: const LogsLoad.loaded(),
              items: items,
              sync: LogsSync.downloaded(logEntryCount: addedCount),
              unsyncedChanges: _unsyncedChanges(summary),
            ),
          );
        } catch (error, stackTrace) {
          addError(error, stackTrace);
          await _refreshSync(emit, endsDownload: true);
        }
    }
  }

  void _onSyncChanged(LogsSyncChanged event, Emitter<LogsState> emit) {
    emit(
      state.copyWith(sync: event.sync, unsyncedChanges: event.unsyncedChanges),
    );
  }

  void _onCreateStarted(LogsCreateStarted event, Emitter<LogsState> emit) {
    emit(
      state.copyWith(
        editor: const LogsEditor.creating(),
        outcome: const LogsOutcome.none(),
      ),
    );
  }

  Future<void> _onStarted(LogsStarted event, Emitter<LogsState> emit) async {
    emit(state.copyWith(load: const LogsLoad.loading(), items: const []));

    try {
      final items = await _logsRepository.getLogs();

      emit(state.copyWith(load: const LogsLoad.loaded(), items: items));
      await _refreshSync(emit);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          load: const LogsLoad.failed(LogsError.loadFailed),
          items: const [],
        ),
      );
    }
  }

  /// Validation follows each change only once a save was tried.
  void _onDraftChanged(LogsDraftChanged event, Emitter<LogsState> emit) {
    final draft = event.draft;
    const noInvalidFields = <LogEntryDraftField>{};

    switch (state.editor) {
      case final LogsEditorCreating editor:
        emit(
          state.copyWith(
            editor: editor.copyWith(
              draft: draft,
              invalidFields: editor.hasSubmitted
                  ? draft.invalidFields
                  : noInvalidFields,
            ),
          ),
        );
      case final LogsEditorEditing editor:
        emit(
          state.copyWith(
            editor: editor.copyWith(
              draft: draft,
              invalidFields: editor.hasSubmitted
                  ? draft.invalidFields
                  : noInvalidFields,
            ),
          ),
        );
      case LogsEditorClosed() || LogsEditorMissing():
        return;
    }
  }

  void _onEditStarted(LogsEditStarted event, Emitter<LogsState> emit) {
    final logEntry = state.items
        .where((item) => item.id == event.logEntryId)
        .firstOrNull;
    if (logEntry == null || _isUpdating) {
      return;
    }

    final draft = LogEntryDraft(
      title: logEntry.title,
      description: logEntry.description,
    );
    emit(
      state.copyWith(
        editor: LogsEditor.editing(
          logEntryId: logEntry.id,
          initialDraft: draft,
          draft: draft,
        ),
      ),
    );
  }

  void _onEditCancelled(LogsEditCancelled event, Emitter<LogsState> emit) {
    final canCancel = switch (state.editor) {
      LogsEditorEditing() => !_isUpdating,
      LogsEditorMissing() => true,
      LogsEditorClosed() || LogsEditorCreating() => false,
    };
    if (canCancel) {
      emit(state.copyWith(editor: const LogsEditor.closed()));
    }
  }

  void _onDraftDiscarded(LogsDraftDiscarded event, Emitter<LogsState> emit) {
    if (state.editor.isOpen) {
      emit(state.copyWith(editor: const LogsEditor.closed()));
    }
  }

  Future<void> _onEditSubmitted(
    LogsEditSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    final editor = state.editor;
    if (editor is! LogsEditorEditing || _isUpdating) {
      return;
    }

    final invalidDraftFields = editor.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          editor: editor.copyWith(
            hasSubmitted: true,
            invalidFields: invalidDraftFields,
            save: LogsSaveStatus.idle,
          ),
        ),
      );
      return;
    }

    if (!editor.isDirty) {
      emit(state.copyWith(editor: const LogsEditor.closed()));
      return;
    }

    final saving = editor.copyWith(
      hasSubmitted: true,
      invalidFields: const <LogEntryDraftField>{},
      save: LogsSaveStatus.saving,
    );
    emit(state.copyWith(editor: saving));

    // A discard while the update runs closes or replaces the editor, so each
    // outcome changes the editor only while it still edits this log entry.
    LogsEditorEditing? sameEditor() => switch (state.editor) {
      final LogsEditorEditing current
          when current.logEntryId == editor.logEntryId =>
        current,
      _ => null,
    };

    try {
      final updatedLogEntry = await _logsRepository.updateLogEntry(
        logEntryId: editor.logEntryId,
        draft: saving.draft,
      );
      emit(
        state.copyWith(
          items: state.items
              .map(
                (logEntry) => logEntry.id == editor.logEntryId
                    ? updatedLogEntry
                    : logEntry,
              )
              .toList(growable: false),
          editor: sameEditor() == null
              ? state.editor
              : const LogsEditor.closed(),
        ),
      );
      await _refreshSync(emit);
    } on InvalidLogEntryDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      final current = sameEditor();
      if (current != null) {
        emit(
          state.copyWith(
            editor: current.copyWith(
              invalidFields: error.invalidFields,
              save: LogsSaveStatus.idle,
            ),
          ),
        );
      }
    } on LogEntryNotFoundException catch (error, stackTrace) {
      addError(error, stackTrace);
      final current = sameEditor();
      if (current != null) {
        emit(
          state.copyWith(
            editor: LogsEditor.missing(
              logEntryId: current.logEntryId,
              initialDraft: current.initialDraft,
              draft: current.draft,
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      final current = sameEditor();
      if (current != null) {
        emit(
          state.copyWith(editor: current.copyWith(save: LogsSaveStatus.failed)),
        );
      }
    }
  }

  Future<void> _onCreateSubmitted(
    LogsCreateSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    final editor = state.editor;
    if (editor is! LogsEditorCreating || editor.isSaving) {
      return;
    }

    final invalidDraftFields = editor.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          editor: editor.copyWith(
            hasSubmitted: true,
            invalidFields: invalidDraftFields,
            save: LogsSaveStatus.idle,
          ),
        ),
      );
      return;
    }

    final saving = editor.copyWith(
      hasSubmitted: true,
      invalidFields: const <LogEntryDraftField>{},
      save: LogsSaveStatus.saving,
    );
    emit(state.copyWith(editor: saving, outcome: const LogsOutcome.none()));

    // A discard while the save runs closes or replaces the editor, so each
    // outcome changes the editor only while it still creates.
    LogsEditorCreating? sameEditor() => switch (state.editor) {
      final LogsEditorCreating current => current,
      _ => null,
    };

    try {
      final logEntry = await _logsRepository.createLogEntry(saving.draft);
      emit(
        state.copyWith(
          items: [logEntry, ...state.items],
          editor: sameEditor() == null
              ? state.editor
              : const LogsEditor.closed(),
          outcome: LogsOutcome.created(logEntry.id),
        ),
      );
      await _refreshSync(emit);
    } on InvalidLogEntryDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      final current = sameEditor();
      if (current != null) {
        emit(
          state.copyWith(
            editor: current.copyWith(
              invalidFields: error.invalidFields,
              save: LogsSaveStatus.idle,
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      final current = sameEditor();
      if (current != null) {
        emit(
          state.copyWith(editor: current.copyWith(save: LogsSaveStatus.failed)),
        );
      }
    }
  }

  Future<void> _onDeleteSubmitted(
    LogsDeleteSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    if (state.deletion is LogsDeletionDeleting) {
      return;
    }

    emit(state.copyWith(deletion: LogsDeletion.deleting(event.logEntryId)));

    try {
      await _logsRepository.deleteLogEntry(event.logEntryId);
      emit(
        state.copyWith(
          items: state.items
              .where((logEntry) => logEntry.id != event.logEntryId)
              .toList(growable: false),
          deletion: const LogsDeletion.idle(),
          outcome: LogsOutcome.deleted(event.logEntryId),
        ),
      );
      await _refreshSync(emit);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(deletion: LogsDeletion.failed(event.logEntryId)));
    }
  }

  bool get _isUpdating => switch (state.editor) {
    LogsEditorEditing(save: LogsSaveStatus.saving) => true,
    _ => false,
  };

  Future<void> _onSyncRequested(
    LogsSyncRequested event,
    Emitter<LogsState> emit,
  ) async {
    if (state.sync.isBusy) {
      return;
    }

    emit(state.copyWith(sync: const LogsSync.waiting()));

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
  /// its progress, and so does a running download unless [endsDownload]; any
  /// other state becomes the pending count or the last sync time.
  Future<void> _refreshSync(
    Emitter<LogsState> emit, {
    bool endsDownload = false,
  }) async {
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
        sync:
            state.sync is LogsSyncSyncing ||
                state.sync is LogsSyncWaiting ||
                (state.sync.isBusy && !endsDownload)
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
