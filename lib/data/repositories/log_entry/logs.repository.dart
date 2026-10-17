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
}
