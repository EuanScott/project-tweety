part of 'logs.bloc.dart';

/// Why the Logs list could not load. Each kind maps to translated text in the
/// widget layer, so the state never holds user-visible wording.
enum LogsError { loadFailed }

/// Whether the Logs list has loaded. Only a failure carries an error kind.
@freezed
sealed class LogsLoad with _$LogsLoad {
  const factory initial() = LogsLoadInitial;

  const factory loading() = LogsLoadLoading;

  const factory loaded() = LogsLoadLoaded;

  const factory failed(LogsError error) = LogsLoadFailed;
}

/// Where the save of an open editor stands.
enum LogsSaveStatus { idle, saving, failed }

/// The one log entry editor. It is closed, writes a new log entry, edits an
/// existing one, or holds an edit whose log entry no longer exists.
///
/// A new log entry always opens empty, so its opening snapshot is the empty
/// draft. Validation errors show only after the first submit, or when the
/// repository rejects a draft.
@freezed
sealed class LogsEditor with _$LogsEditor {
  const new _();

  const factory closed() = LogsEditorClosed;

  const factory creating({
    @Default(LogsEditor.emptyDraft) LogEntryDraft draft,
    @Default(false) bool hasSubmitted,
    @Default(<LogEntryDraftField>{}) Set<LogEntryDraftField> invalidFields,
    @Default(LogsSaveStatus.idle) LogsSaveStatus save,
  }) = LogsEditorCreating;

  const factory editing({
    required String logEntryId,
    required LogEntryDraft initialDraft,
    required LogEntryDraft draft,
    @Default(false) bool hasSubmitted,
    @Default(<LogEntryDraftField>{}) Set<LogEntryDraftField> invalidFields,
    @Default(LogsSaveStatus.idle) LogsSaveStatus save,
  }) = LogsEditorEditing;

  /// The save found no log entry to update. The draft stays so leaving still
  /// asks before discarding it, but it cannot be saved again.
  const factory missing({
    required String logEntryId,
    required LogEntryDraft initialDraft,
    required LogEntryDraft draft,
  }) = LogsEditorMissing;

  static const emptyDraft = LogEntryDraft(title: '', description: '');

  bool get isOpen => this is! LogsEditorClosed;

  /// Whether the untrimmed editor values differ from their opening snapshot.
  bool get isDirty => switch (this) {
    LogsEditorClosed() => false,
    LogsEditorCreating(:final draft) => draft != emptyDraft,
    LogsEditorEditing(:final draft, :final initialDraft) ||
    LogsEditorMissing(
      :final draft,
      :final initialDraft,
    ) => draft != initialDraft,
  };

  bool get isSaving => switch (this) {
    LogsEditorCreating(save: LogsSaveStatus.saving) ||
    LogsEditorEditing(save: LogsSaveStatus.saving) => true,
    _ => false,
  };

  bool get hasSaveFailed => switch (this) {
    LogsEditorCreating(save: LogsSaveStatus.failed) ||
    LogsEditorEditing(save: LogsSaveStatus.failed) => true,
    _ => false,
  };

  /// This editor with its save at [save]. Only an editor that can save
  /// changes; any other stays as it is.
  LogsEditor withSave(
    LogsSaveStatus save, {
    bool? hasSubmitted,
    Set<LogEntryDraftField>? invalidFields,
  }) => switch (this) {
    final LogsEditorCreating editor => editor.copyWith(
      hasSubmitted: hasSubmitted ?? editor.hasSubmitted,
      invalidFields: invalidFields ?? editor.invalidFields,
      save: save,
    ),
    final LogsEditorEditing editor => editor.copyWith(
      hasSubmitted: hasSubmitted ?? editor.hasSubmitted,
      invalidFields: invalidFields ?? editor.invalidFields,
      save: save,
    ),
    _ => this,
  };

  LogsEditor get savingDraft => withSave(
    LogsSaveStatus.saving,
    hasSubmitted: true,
    invalidFields: const <LogEntryDraftField>{},
  );

  Set<LogEntryDraftField> get invalidFields => switch (this) {
    LogsEditorCreating(:final invalidFields) ||
    LogsEditorEditing(:final invalidFields) => invalidFields,
    _ => const <LogEntryDraftField>{},
  };
}

/// Where a delete in progress stands. Each state names the log entry it is
/// about. A finished delete is reported by [LogsOutcome.deleted].
@freezed
sealed class LogsDeletion with _$LogsDeletion {
  const factory idle() = LogsDeletionIdle;

  const factory deleting(String logEntryId) = LogsDeletionDeleting;

  const factory failed(String logEntryId) = LogsDeletionFailed;
}

/// The latest create or delete that finished. The page navigates when this
/// changes, so a later outcome always replaces an earlier one and a create
/// cannot hide a delete after it.
@freezed
sealed class LogsOutcome with _$LogsOutcome {
  const factory none() = LogsOutcomeNone;

  const factory created(String logEntryId) = LogsOutcomeCreated;

  const factory deleted(String logEntryId) = LogsOutcomeDeleted;
}

@freezed
sealed class LogsDetail with _$LogsDetail {
  const factory loading() = LogsDetailLoading;

  const factory success(LogEntry logEntry) = LogsDetailSuccess;

  const factory missing() = LogsDetailMissing;

  const factory failure(LogsError error) = LogsDetailFailure;
}

@freezed
abstract class LogsState with _$LogsState {
  const new _();

  const factory({
    @Default(LogsLoad.initial()) LogsLoad load,
    @Default(<LogEntry>[]) List<LogEntry> items,
    @Default(LogsEditor.closed()) LogsEditor editor,

    /// The log entry the latest create saved, kept until the next create
    /// starts. The page opens its details when this changes.
    /// The page opens the created log entry, or leaves a deleted one, when
    /// this changes. The next create starts clears it.
    @Default(LogsOutcome.none()) LogsOutcome outcome,
    @Default(LogsDeletion.idle()) LogsDeletion deletion,
  }) = _LogsState;

  /// Whether the list has no loaded result yet, so the page shows progress.
  bool get isLoading => switch (load) {
    LogsLoadInitial() || LogsLoadLoading() => true,
    _ => false,
  };

  bool get isDraftDirty => editor.isDirty;

  bool isEditingLogEntry(String logEntryId) => switch (editor) {
    LogsEditorEditing(logEntryId: final id) ||
    LogsEditorMissing(logEntryId: final id) => id == logEntryId,
    _ => false,
  };

  bool hasMissingEditFor(String logEntryId) => switch (editor) {
    LogsEditorMissing(logEntryId: final id) => id == logEntryId,
    _ => false,
  };

  bool isDeletingLogEntry(String logEntryId) =>
      deletion == LogsDeletion.deleting(logEntryId);

  bool hasDeleteErrorFor(String logEntryId) =>
      deletion == LogsDeletion.failed(logEntryId);

  LogsDetail detailFor(String logEntryId) {
    switch (load) {
      case LogsLoadInitial() || LogsLoadLoading():
        return const .loading();
      case LogsLoadFailed(:final error):
        return .failure(error);
      case LogsLoadLoaded():
        break;
    }

    for (final logEntry in items) {
      if (logEntry.id == logEntryId) {
        return .success(logEntry);
      }
    }

    return const .missing();
  }
}
