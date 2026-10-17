part of 'logs.bloc.dart';

enum LogsStatus { initial, loading, success, failure }

enum LogsCreateStatus { idle, creating, success, failure }

enum LogsEditStatus { idle, updating, success, failure, notFound }

enum LogsDeleteStatus { idle, deleting, success, failure }

@freezed
sealed class LogsDetail with _$LogsDetail {
  const factory loading() = LogsDetailLoading;

  const factory success(LogEntry logEntry) = LogsDetailSuccess;

  const factory missing() = LogsDetailMissing;

  const factory failure(String errorMessage) = LogsDetailFailure;
}

/// What a sync would push for a log entry that has not reached the Account yet.
enum UnsyncedLogEntryChange { created, updated }

/// Where a sync, or a background download of log entries, stands.
///
/// Counts are changes, so a deleted log entry waiting to sync is counted even
/// though it has no row in the list.
@freezed
sealed class LogsSync with _$LogsSync {
  const new _();

  const factory upToDate({DateTime? lastSyncedAt}) = LogsSyncUpToDate;

  const factory pending({required int changeCount}) = LogsSyncPending;

  const factory syncing({required int savedCount, required int changeCount}) =
      LogsSyncSyncing;

  const factory synced({required int changeCount}) = LogsSyncSynced;

  const factory partial({required int savedCount, required int changeCount}) =
      LogsSyncPartial;

  const factory offline({required int changeCount}) = LogsSyncOffline;

  const factory failed({required int changeCount}) = LogsSyncFailed;

  const factory alreadyUpToDate() = LogsSyncAlreadyUpToDate;

  const factory downloading({required int logEntryCount}) = LogsSyncDownloading;

  const factory downloaded({required int logEntryCount}) = LogsSyncDownloaded;

  /// Whether a sync or a download is running, so a new sync cannot start.
  bool get isBusy => switch (this) {
    LogsSyncSyncing() || LogsSyncDownloading() => true,
    _ => false,
  };
}

@freezed
abstract class LogsState with _$LogsState {
  const new _();

  const factory({
    @Default(LogsStatus.initial) LogsStatus status,
    @Default(<LogEntry>[]) List<LogEntry> items,
    String? errorMessage,
    @Default(LogEntryDraft(title: '', description: '')) LogEntryDraft draft,
    LogEntryDraft? initialDraft,
    @Default(<LogEntryDraftField>{}) Set<LogEntryDraftField> invalidDraftFields,
    @Default(false) bool hasSubmittedCreate,
    @Default(LogsCreateStatus.idle) LogsCreateStatus createStatus,
    @Default(false) bool createError,
    String? createdLogEntryId,
    String? editingLogEntryId,
    @Default(false) bool hasSubmittedEdit,
    @Default(LogsEditStatus.idle) LogsEditStatus editStatus,
    @Default(false) bool editError,
    String? missingEditLogEntryId,
    String? updatedLogEntryId,
    @Default(LogsDeleteStatus.idle) LogsDeleteStatus deleteStatus,
    String? deletingLogEntryId,
    String? deleteErrorLogEntryId,
    String? deletedLogEntryId,
    @Default(LogsSync.upToDate()) LogsSync sync,
    @Default(<String, UnsyncedLogEntryChange>{})
    Map<String, UnsyncedLogEntryChange> unsyncedChanges,
  }) = _LogsState;

  bool get isInitial => status == LogsStatus.initial;

  bool get isLoading => status == LogsStatus.loading;

  bool get isSuccess => status == LogsStatus.success;

  bool get isFailure => status == LogsStatus.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  bool get isCreating => createStatus == LogsCreateStatus.creating;

  /// Whether the untrimmed editor values differ from their opening snapshot.
  bool get isDraftDirty => initialDraft != null && draft != initialDraft;

  bool get isDeleting => deleteStatus == LogsDeleteStatus.deleting;

  bool get isEditing => editingLogEntryId != null;

  bool get isUpdating => editStatus == LogsEditStatus.updating;

  bool isEditingLogEntry(String logEntryId) => editingLogEntryId == logEntryId;

  bool hasMissingEditFor(String logEntryId) =>
      editStatus == LogsEditStatus.notFound &&
      missingEditLogEntryId == logEntryId;

  bool isDeletingLogEntry(String logEntryId) =>
      isDeleting && deletingLogEntryId == logEntryId;

  bool hasDeleteErrorFor(String logEntryId) =>
      deleteStatus == LogsDeleteStatus.failure &&
      deleteErrorLogEntryId == logEntryId;

  LogsDetail detailFor(String logEntryId) {
    if (isInitial || isLoading) {
      return const .loading();
    }

    if (isFailure) {
      return .failure(errorMessage ?? 'Unable to load logs right now.');
    }

    for (final logEntry in items) {
      if (logEntry.id == logEntryId) {
        return .success(logEntry);
      }
    }

    return const .missing();
  }
}
