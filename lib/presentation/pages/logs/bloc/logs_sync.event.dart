part of 'logs_sync.bloc.dart';

@freezed
sealed class LogsSyncEvent with _$LogsSyncEvent {
  /// Re-reads what is pending: on start, on a refresh of the list, and after
  /// a change is saved.
  const factory refreshed() = LogsSyncRefreshed;

  /// Pushes every pending change to the Account.
  const factory requested() = LogsSyncRequested;

  /// A download reported how it is adding log entries to the device.
  const factory downloadProgressed(LogsDownloadProgress progress) =
      LogsSyncDownloadProgressed;
}
