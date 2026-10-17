import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

class MockLogsDataSource implements LogsDataSource {
  final List<LogEntryDto> _logs = List<LogEntryDto>.generate(
    10,
    (index) => LogEntryDto(
      id: 'card-${index + 1}',
      title: 'Entry title ${index + 1}',
      description:
          'This is the body copy for entry number ${index + 1}. '
          'You can replace this with whatever description you want.',
    ),
  );

  @override
  Future<List<LogEntryDto>> getLogs() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<LogEntryDto>.unmodifiable(
      _logs.where(
        (logEntry) => logEntry.syncStatus != LogEntrySyncStatus.deleted,
      ),
    );
  }

  @override
  Future<LogEntryDto?> getLogEntryById(String logEntryId) async {
    final logs = await getLogs();

    for (final logEntry in logs) {
      if (logEntry.id == logEntryId) {
        return logEntry;
      }
    }

    return null;
  }

  @override
  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry) async {
    final now = DateTime.now().toUtc();
    final createdLogEntry = LogEntryDto(
      id: logEntry.id,
      title: logEntry.title,
      description: logEntry.description,
      syncStatus: LogEntrySyncStatus.created,
      createdAt: now,
      updatedAt: now,
    );
    _logs.insert(0, createdLogEntry);
    return createdLogEntry;
  }

  @override
  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry) async {
    final index = _logs.indexWhere((item) => item.id == logEntry.id);
    if (index == -1 || _logs[index].syncStatus == LogEntrySyncStatus.deleted) {
      return null;
    }

    final existingLogEntry = _logs[index];
    final updatedLogEntry = LogEntryDto(
      id: logEntry.id,
      title: logEntry.title,
      description: logEntry.description,
      syncStatus: existingLogEntry.syncStatus == LogEntrySyncStatus.created
          ? LogEntrySyncStatus.created
          : LogEntrySyncStatus.updated,
      createdAt: existingLogEntry.createdAt,
      updatedAt: DateTime.now().toUtc(),
      lastSyncedAt: existingLogEntry.lastSyncedAt,
    );
    _logs[index] = updatedLogEntry;
    return updatedLogEntry;
  }

  @override
  Future<void> deleteLogEntry(String logEntryId) async {
    final index = _logs.indexWhere((logEntry) => logEntry.id == logEntryId);
    if (index == -1) {
      return;
    }

    final existingLogEntry = _logs[index];
    if (existingLogEntry.syncStatus == LogEntrySyncStatus.created) {
      _logs.removeAt(index);
      return;
    }

    final now = DateTime.now().toUtc();
    _logs[index] = LogEntryDto(
      id: existingLogEntry.id,
      title: existingLogEntry.title,
      description: existingLogEntry.description,
      syncStatus: LogEntrySyncStatus.deleted,
      createdAt: existingLogEntry.createdAt,
      updatedAt: now,
      lastSyncedAt: existingLogEntry.lastSyncedAt,
      deletedAt: now,
    );
  }

  @override
  Future<List<LogEntryDto>> getUnsyncedLogs() async {
    return List<LogEntryDto>.unmodifiable(
      _logs.where(
        (logEntry) => logEntry.syncStatus != LogEntrySyncStatus.synced,
      ),
    );
  }

  @override
  Future<void> markLogsSynced(List<LogEntryDto> pushedLogs) async {
    if (pushedLogs.isEmpty) {
      return;
    }

    final pushedUpdatedAt = {
      for (final logEntry in pushedLogs) logEntry.id: logEntry.updatedAt,
    };
    bool unchangedSincePush(LogEntryDto logEntry) =>
        pushedUpdatedAt.containsKey(logEntry.id) &&
        pushedUpdatedAt[logEntry.id] == logEntry.updatedAt;

    _logs.removeWhere(
      (logEntry) =>
          unchangedSincePush(logEntry) &&
          logEntry.syncStatus == LogEntrySyncStatus.deleted,
    );

    final now = DateTime.now().toUtc();
    final presentIds = {for (final logEntry in _logs) logEntry.id};
    for (final logEntry in pushedLogs) {
      if (logEntry.syncStatus != LogEntrySyncStatus.deleted &&
          !presentIds.contains(logEntry.id)) {
        _logs.add(
          LogEntryDto(
            id: logEntry.id,
            title: logEntry.title,
            description: logEntry.description,
            syncStatus: LogEntrySyncStatus.deleted,
            updatedAt: now,
            deletedAt: now,
          ),
        );
      }
    }
    for (var index = 0; index < _logs.length; index++) {
      final logEntry = _logs[index];
      if (!unchangedSincePush(logEntry)) {
        continue;
      }

      _logs[index] = LogEntryDto(
        id: logEntry.id,
        title: logEntry.title,
        description: logEntry.description,
        syncStatus: LogEntrySyncStatus.synced,
        createdAt: logEntry.createdAt,
        updatedAt: logEntry.updatedAt,
        lastSyncedAt: now,
      );
    }
  }
}
