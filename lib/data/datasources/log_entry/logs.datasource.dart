import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

abstract class LogsDataSource {
  Future<List<LogEntryDto>> getLogs();

  Future<LogEntryDto?> getLogEntryById(String logEntryId);

  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry);

  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry);

  Future<void> deleteLogEntry(String logEntryId);

  Future<List<LogEntryDto>> getUnsyncedLogs();

  /// Every log entry of the Account in one read, deleted tombstones included.
  Future<List<LogEntryDto>> getAllLogs();

  /// Adds each downloaded log entry whose id no row on the device holds, as
  /// `synced`, oldest change first, in one transaction. A row already on the
  /// device always wins, whatever its state or owner. Throws an
  /// [AccountNotSignedInException], and adds nothing, when an entry belongs to
  /// another Account than the signed-in one or nobody is signed in. Calls
  /// [onAdding] inside the transaction, after those checks and before the
  /// first insert, with how many it is about to add, and only when that is
  /// more than zero. Returns how many were added.
  Future<int> addDownloadedLogs(
    List<LogEntryDto> downloadedLogs, {
    void Function(int addingCount)? onAdding,
  });

  /// Acknowledges log entries the server confirmed. Each entry is the snapshot
  /// that was pushed; a log entry changed since its snapshot stays unsynced.
  Future<void> markLogsSynced(List<LogEntryDto> pushedLogs);
}
