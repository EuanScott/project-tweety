import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

abstract class LogsDataSource {
  Future<List<LogEntryDto>> getLogs();

  Future<LogEntryDto?> getLogEntryById(String logEntryId);

  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry);

  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry);

  Future<void> deleteLogEntry(String logEntryId);

  Future<List<LogEntryDto>> getUnsyncedLogs();

  /// Acknowledges log entries the server confirmed. Each entry is the snapshot
  /// that was pushed; a log entry changed since its snapshot stays unsynced.
  Future<void> markLogsSynced(List<LogEntryDto> pushedLogs);
}
