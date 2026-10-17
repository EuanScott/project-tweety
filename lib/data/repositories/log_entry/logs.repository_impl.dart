import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';

import 'logs.repository.dart';

@LazySingleton(as: LogsRepository)
class const LogsRepositoryImpl(
  final LogsDataSource _dataSource,
  final LogEntryIdGenerator _logEntryIdGenerator,
  final LogsRemoteDataSource _remoteDataSource,
) implements LogsRepository {
  @override
  Future<List<LogEntry>> getLogs() async {
    final items = await _dataSource.getLogs();
    return items.map((item) => item.toValue()).toList(growable: false);
  }

  @override
  Future<LogEntry?> getLogEntryById(String logEntryId) async {
    final item = await _dataSource.getLogEntryById(logEntryId);
    return item?.toValue();
  }

  @override
  Future<LogEntry> createLogEntry(LogEntryDraft draft) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.createLogEntry(
      LogEntryDto(
        id: _logEntryIdGenerator.generate(),
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    return item.toValue();
  }

  @override
  Future<LogEntry> updateLogEntry({
    required String logEntryId,
    required LogEntryDraft draft,
  }) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.updateLogEntry(
      LogEntryDto(
        id: logEntryId,
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    if (item == null) {
      throw LogEntryNotFoundException(logEntryId);
    }
    return item.toValue();
  }

  @override
  Future<void> deleteLogEntry(String logEntryId) {
    return _dataSource.deleteLogEntry(logEntryId);
  }

  @override
  Future<LogsSyncSummary> getSyncSummary() async {
    final unsyncedLogs = await _dataSource.getUnsyncedLogs();
    final logs = await _dataSource.getLogs();
    DateTime? lastSyncedAt;
    for (final logEntry in logs) {
      final logEntrySyncedAt = logEntry.lastSyncedAt;
      if (logEntrySyncedAt != null &&
          (lastSyncedAt == null || logEntrySyncedAt.isAfter(lastSyncedAt))) {
        lastSyncedAt = logEntrySyncedAt;
      }
    }

    return LogsSyncSummary(
      pendingChanges: {
        for (final logEntry in unsyncedLogs)
          logEntry.id: switch (logEntry.syncStatus) {
            LogEntrySyncStatus.created => PendingLogEntryChange.created,
            LogEntrySyncStatus.deleted => PendingLogEntryChange.deleted,
            LogEntrySyncStatus.updated ||
            LogEntrySyncStatus.synced => PendingLogEntryChange.updated,
          },
      },
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  Future<LogsSyncResult> syncLogs({
    void Function(int savedCount, int changeCount)? onProgress,
  }) async {
    final pendingLogs = await _dataSource.getUnsyncedLogs();
    final changeCount = pendingLogs.length;
    if (changeCount == 0) {
      return const LogsSyncResult(changeCount: 0, savedCount: 0);
    }

    onProgress?.call(0, changeCount);
    var savedCount = 0;
    final outcomes = await _remoteDataSource.pushLogs(
      pendingLogs,
      onPushed: (_, outcome) {
        if (outcome == LogEntryPushOutcome.confirmed) {
          onProgress?.call(++savedCount, changeCount);
        }
      },
    );
    final confirmedLogs = [
      for (final logEntry in pendingLogs)
        if (outcomes[logEntry.id] == LogEntryPushOutcome.confirmed) logEntry,
    ];
    await _dataSource.markLogsSynced(confirmedLogs);

    final failures = outcomes.values.where(
      (outcome) => outcome != LogEntryPushOutcome.confirmed,
    );

    return LogsSyncResult(
      changeCount: changeCount,
      savedCount: confirmedLogs.length,
      onlyNetworkFailures:
          failures.isNotEmpty &&
          failures.every(
            (outcome) => outcome == LogEntryPushOutcome.networkFailure,
          ),
    );
  }

  LogEntryDraft _validatedTrimmedDraft(LogEntryDraft draft) {
    final invalidFields = draft.invalidFields;
    if (invalidFields.isNotEmpty) {
      throw InvalidLogEntryDraftException(invalidFields);
    }
    return draft.trimmed();
  }
}
