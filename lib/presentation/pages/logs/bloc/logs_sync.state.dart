part of 'logs_sync.bloc.dart';

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

  /// A sync was requested and has not started, for example because a
  /// download is still running. Its change count is not known yet.
  const factory waiting() = LogsSyncWaiting;

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
    LogsSyncWaiting() || LogsSyncSyncing() || LogsSyncDownloading() => true,
    _ => false,
  };
}

/// Where the Sync row stands, and which log entries carry an unsynced change.
@freezed
abstract class LogsSyncState with _$LogsSyncState {
  const factory({
    @Default(LogsSync.upToDate()) LogsSync sync,
    @Default(<String, UnsyncedLogEntryChange>{})
    Map<String, UnsyncedLogEntryChange> unsyncedChanges,
  }) = _LogsSyncState;
}
