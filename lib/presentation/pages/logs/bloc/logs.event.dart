part of 'logs.bloc.dart';

@freezed
sealed class LogsEvent with _$LogsEvent {
  const factory started() = LogsStarted;

  const factory createStarted() = LogsCreateStarted;

  const factory draftChanged(LogEntryDraft draft) = LogsDraftChanged;

  const factory createSubmitted() = LogsCreateSubmitted;

  const factory editStarted(String logEntryId) = LogsEditStarted;

  const factory editCancelled() = LogsEditCancelled;

  const factory draftDiscarded() = LogsDraftDiscarded;

  const factory editSubmitted() = LogsEditSubmitted;

  const factory deleteSubmitted(String logEntryId) = LogsDeleteSubmitted;

  /// Pushes every pending change to the Account.
  const factory syncRequested() = LogsSyncRequested;

  /// A download reported how it is adding log entries to the device.
  const factory downloadProgressed(LogsDownloadProgress progress) =
      LogsDownloadProgressed;

  /// Replaces where sync stands and which log entries carry an unsynced change.
  const factory syncChanged(
    LogsSync sync, {
    @Default(<String, UnsyncedLogEntryChange>{})
    Map<String, UnsyncedLogEntryChange> unsyncedChanges,
  }) = LogsSyncChanged;
}
