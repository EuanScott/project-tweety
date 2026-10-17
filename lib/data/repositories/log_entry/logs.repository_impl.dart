import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';

import 'logs.repository.dart';

/// It lives as long as the app, so its download stream is never closed.
@LazySingleton(as: LogsRepository)
class LogsRepositoryImpl(
  final LogsDataSource _dataSource,
  final LogEntryIdGenerator _logEntryIdGenerator,
  final LogsRemoteDataSource _remoteDataSource,
) implements LogsRepository {
  final _downloadProgress = StreamController<LogsDownloadProgress>.broadcast();

  /// The end of the last sync or download, so the next one starts after it.
  Future<void> _remoteWork = Future<void>.value();
  Future<void>? _download;
  var _downloadAgain = false;

  @override
  Stream<LogsDownloadProgress> get downloadProgress => _downloadProgress.stream;

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
    final logs = await _dataSource.getAllLogs();
    final pendingChanges = <String, PendingLogEntryChange>{};
    DateTime? lastSyncedAt;
    for (final logEntry in logs) {
      final change = switch (logEntry.syncStatus) {
        LogEntrySyncStatus.created => PendingLogEntryChange.created,
        LogEntrySyncStatus.deleted => PendingLogEntryChange.deleted,
        LogEntrySyncStatus.updated => PendingLogEntryChange.updated,
        LogEntrySyncStatus.synced => null,
      };
      if (change != null) {
        pendingChanges[logEntry.id] = change;
      }

      final logEntrySyncedAt = logEntry.lastSyncedAt;
      if (logEntry.syncStatus != LogEntrySyncStatus.deleted &&
          logEntrySyncedAt != null &&
          (lastSyncedAt == null || logEntrySyncedAt.isAfter(lastSyncedAt))) {
        lastSyncedAt = logEntrySyncedAt;
      }
    }

    return LogsSyncSummary(
      pendingChanges: pendingChanges,
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  Future<LogsSyncResult> syncLogs({
    void Function(int savedCount, int changeCount)? onProgress,
  }) => _oneAtATime(() => _sync(onProgress));

  @override
  Future<void> downloadLogs() {
    if (_download case final running?) {
      _downloadAgain = true;
      return running;
    }

    return _download = _downloadUntilCaughtUp().whenComplete(
      () => _download = null,
    );
  }

  /// Runs once more for each request made while a download ran, for example
  /// a new sign-in. A failure is dropped when another run supersedes it.
  Future<void> _downloadUntilCaughtUp() async {
    while (true) {
      _downloadAgain = false;
      try {
        await _oneAtATime(_downloadOnce);
        if (!_downloadAgain) {
          return;
        }
      } catch (_) {
        if (!_downloadAgain) {
          rethrow;
        }
      }
    }
  }

  /// Progress starts only once the write has confirmed the Account and
  /// counted what is missing, so a Session change never shows `adding`.
  Future<void> _downloadOnce() async {
    final remoteLogs = await _remoteDataSource.fetchLogs();
    var isAdding = false;
    var addedCount = 0;
    try {
      addedCount = await _dataSource.addDownloadedLogs(
        remoteLogs,
        onAdding: (addingCount) {
          isAdding = true;
          _downloadProgress.add(
            LogsDownloadProgress.adding(logEntryCount: addingCount),
          );
        },
      );
    } on AccountNotSignedInException {
      throw const LogsSessionChangedException();
    } finally {
      if (isAdding) {
        _downloadProgress.add(
          LogsDownloadProgress.finished(addedCount: addedCount),
        );
      }
    }
  }

  Future<T> _oneAtATime<T>(Future<T> Function() action) {
    final result = _remoteWork.then((_) => action());
    _remoteWork = result.then<void>((_) {}, onError: (Object _) {});

    return result;
  }

  Future<LogsSyncResult> _sync(
    void Function(int savedCount, int changeCount)? onProgress,
  ) async {
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
