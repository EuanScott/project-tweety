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

  /// A download reported how it is adding log entries to the device.
  const factory downloadProgressed(LogsDownloadProgress progress) =
      LogsDownloadProgressed;
}
