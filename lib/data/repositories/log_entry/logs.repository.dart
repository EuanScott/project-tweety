import 'package:freezed_annotation/freezed_annotation.dart';

part 'logs.repository.freezed.dart';

@freezed
abstract class LogEntry with _$LogEntry {
  const factory({
    required String id,
    required String title,
    required String description,
  }) = _LogEntry;
}

@freezed
abstract class LogEntryDraft with _$LogEntryDraft {
  const factory({required String title, required String description}) =
      _LogEntryDraft;

  const new _();

  Set<LogEntryDraftField> get invalidFields {
    return {
      if (title.trim().isEmpty) LogEntryDraftField.title,
      if (description.trim().isEmpty) LogEntryDraftField.description,
    };
  }

  LogEntryDraft trimmed() {
    return LogEntryDraft(title: title.trim(), description: description.trim());
  }
}

enum LogEntryDraftField { title, description }

class InvalidLogEntryDraftException implements Exception {
  new(Iterable<LogEntryDraftField> invalidFields)
    : invalidFields = Set<LogEntryDraftField>.unmodifiable(invalidFields);

  final Set<LogEntryDraftField> invalidFields;
}

class const LogEntryNotFoundException(final String logEntryId)
    implements Exception;

/// The Account's copy could not be reached in time, for example because the
/// device is offline. Trying again later may succeed.
class const LogsAccountUnreachableException() implements Exception;

/// The Session signed out, or changed Account, while a download ran. Nothing
/// was written for it, and the next sign-in downloads again. It is expected,
/// not a fault.
class const LogsSessionChangedException() implements Exception;

/// A change on this device that the Account's copy does not have yet.
enum PendingLogEntryChange { created, updated, deleted }

/// Where sync stands while no sync is running.
@freezed
abstract class LogsSyncSummary with _$LogsSyncSummary {
  const factory({
    @Default(<String, PendingLogEntryChange>{})
    Map<String, PendingLogEntryChange> pendingChanges,

    /// The latest time any log entry still on this device was synced.
    DateTime? lastSyncedAt,
  }) = _LogsSyncSummary;
}

/// How one sync ended. [changeCount] is what it tried to push, and
/// [savedCount] is what the server confirmed.
@freezed
abstract class LogsSyncResult with _$LogsSyncResult {
  const factory({
    required int changeCount,
    required int savedCount,

    /// Whether every change that was not saved failed because the server
    /// could not be reached, rather than because it refused the change.
    @Default(false) bool onlyNetworkFailures,
  }) = _LogsSyncResult;
}

/// How a download is adding log entries to the device. A download reports
/// nothing until it knows it has something to add, and then reports `adding`
/// followed by `finished`. A download that adds nothing, or fails before it
/// adds, reports nothing at all.
@freezed
sealed class LogsDownloadProgress with _$LogsDownloadProgress {
  /// The Account's copy holds [logEntryCount] log entries that the device does
  /// not, and they are being added.
  const factory adding({required int logEntryCount}) = LogsDownloadAdding;

  /// The download ended. [addedCount] can be lower than the count it was
  /// adding, down to zero when the write failed.
  const factory finished({required int addedCount}) = LogsDownloadFinished;
}

abstract class LogsRepository {
  Future<List<LogEntry>> getLogs();

  Future<LogEntry?> getLogEntryById(String logEntryId);

  Future<LogEntry> createLogEntry(LogEntryDraft draft);

  Future<LogEntry> updateLogEntry({
    required String logEntryId,
    required LogEntryDraft draft,
  });

  Future<void> deleteLogEntry(String logEntryId);

  Future<LogsSyncSummary> getSyncSummary();

  /// Pushes every pending change. Calls [onProgress] once before the push
  /// with no changes saved, then again as the server confirms each one.
  Future<LogsSyncResult> syncLogs({
    void Function(int savedCount, int changeCount)? onProgress,
  });

  /// Adds every log entry the Account's copy holds and the device does not.
  /// A log entry already on the device is never changed. A sync and a
  /// download never run at the same time: each waits for the other. Asked
  /// for while one runs, it joins that download, and one more runs after it.
  /// Throws [LogsAccountUnreachableException] when the Account's copy cannot
  /// be reached, and [LogsSessionChangedException] when the Session signed
  /// out or changed Account before the write.
  Future<void> downloadLogs();

  /// Emits as a download adds log entries to the device.
  Stream<LogsDownloadProgress> get downloadProgress;
}
