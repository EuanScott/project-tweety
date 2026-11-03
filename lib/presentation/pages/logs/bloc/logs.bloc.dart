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
  /// ends. A download that added nothing leaves the list alone.
  Future<void> _onDownloadProgressed(
    LogsDownloadProgressed event,
    Emitter<LogsState> emit,
  ) async {
    if (event.progress case LogsDownloadFinished(:final addedCount)
        when addedCount > 0) {
      try {
        final items = await _logsRepository.getLogs();
        emit(state.copyWith(load: const LogsLoad.loaded(), items: items));
      } catch (error, stackTrace) {
        addError(error, stackTrace);
      }
    }
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
    if (editor is! LogsEditorEditing ||
        editor.isSaving ||
        _showsInvalidFields(emit, editor, editor.draft)) {
      return;
    }

    if (!editor.isDirty) {
      emit(state.copyWith(editor: const LogsEditor.closed()));
      return;
    }

    emit(state.copyWith(editor: editor.savingDraft));

    await _save(
      emit,
      isSameEditor: (current) =>
          current is LogsEditorEditing &&
          current.logEntryId == editor.logEntryId,
      write: () => _logsRepository.updateLogEntry(
        logEntryId: editor.logEntryId,
        draft: editor.draft,
      ),
      withSaved: (updatedLogEntry) => state.copyWith(
        items: state.items
            .map(
              (logEntry) =>
                  logEntry.id == editor.logEntryId ? updatedLogEntry : logEntry,
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _onCreateSubmitted(
    LogsCreateSubmitted event,
    Emitter<LogsState> emit,
  ) async {
    final editor = state.editor;
    if (editor is! LogsEditorCreating ||
        editor.isSaving ||
        _showsInvalidFields(emit, editor, editor.draft)) {
      return;
    }

    emit(
      state.copyWith(
        editor: editor.savingDraft,
        outcome: const LogsOutcome.none(),
      ),
    );

    await _save(
      emit,
      isSameEditor: (current) => current is LogsEditorCreating,
      write: () => _logsRepository.createLogEntry(editor.draft),
      withSaved: (logEntry) => state.copyWith(
        items: [logEntry, ...state.items],
        outcome: LogsOutcome.created(logEntry.id),
      ),
    );
  }

  bool _showsInvalidFields(
    Emitter<LogsState> emit,
    LogsEditor editor,
    LogEntryDraft draft,
  ) {
    final invalidFields = draft.invalidFields;
    if (invalidFields.isEmpty) {
      return false;
    }

    emit(
      state.copyWith(
        editor: editor.withSave(
          LogsSaveStatus.idle,
          hasSubmitted: true,
          invalidFields: invalidFields,
        ),
      ),
    );
    return true;
  }

  /// A discard while the save runs closes or replaces the editor, so each
  /// outcome changes the editor only while [isSameEditor] holds.
  Future<void> _save(
    Emitter<LogsState> emit, {
    required bool Function(LogsEditor current) isSameEditor,
    required Future<LogEntry> Function() write,
    required LogsState Function(LogEntry saved) withSaved,
  }) async {
    void updateSameEditor(LogsEditor Function(LogsEditor current) update) {
      if (isSameEditor(state.editor)) {
        emit(state.copyWith(editor: update(state.editor)));
      }
    }

    try {
      final saved = await write();
      emit(
        withSaved(saved).copyWith(
          editor: isSameEditor(state.editor)
              ? const LogsEditor.closed()
              : state.editor,
        ),
      );
    } on InvalidLogEntryDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      updateSameEditor(
        (current) => current.withSave(
          LogsSaveStatus.idle,
          invalidFields: error.invalidFields,
        ),
      );
    } on LogEntryNotFoundException catch (error, stackTrace) {
      addError(error, stackTrace);
      updateSameEditor(
        (current) => switch (current) {
          final LogsEditorEditing editor => LogsEditor.missing(
            logEntryId: editor.logEntryId,
            initialDraft: editor.initialDraft,
            draft: editor.draft,
          ),
          _ => current.withSave(LogsSaveStatus.failed),
        },
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      updateSameEditor((current) => current.withSave(LogsSaveStatus.failed));
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
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(deletion: LogsDeletion.failed(event.logEntryId)));
    }
  }

  bool get _isUpdating => switch (state.editor) {
    LogsEditorEditing(save: LogsSaveStatus.saving) => true,
    _ => false,
  };
}
