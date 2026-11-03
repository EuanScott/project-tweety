import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

part 'logs_sync.event.dart';
part 'logs_sync.state.dart';
part 'logs_sync.bloc.freezed.dart';

/// Decides what the Sync row shows. A Sync a person asked for takes precedence
/// over a Download: while it waits or runs, the row does not show the Download
/// ([ADR-0008](../../../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)).
@injectable
class LogsSyncBloc extends Bloc<LogsSyncEvent, LogsSyncState> {
  new(this._logsRepository) : super(const LogsSyncState()) {
    on<LogsSyncRefreshed>((event, emit) => _refresh(emit));
    on<LogsSyncRequested>(_onRequested, transformer: droppable());
    on<LogsSyncDownloadProgressed>(
      _onDownloadProgressed,
      transformer: sequential(),
    );
    _downloadSubscription = _logsRepository.downloadProgress.listen(
      (progress) => add(LogsSyncDownloadProgressed(progress)),
    );
    _savedChangesSubscription = _logsRepository.savedChanges.listen(
      (_) => add(const LogsSyncRefreshed()),
    );
  }

  final LogsRepository _logsRepository;
  late final StreamSubscription<LogsDownloadProgress> _downloadSubscription;
  late final StreamSubscription<void> _savedChangesSubscription;

  /// Numbers each summary read in the order it started.
  var _readsStarted = 0;

  /// The newest read the state already reflects. An older answer is dropped,
  /// so it cannot replace a newer status or newer markers.
  var _newestRead = 0;

  @override
  Future<void> close() async {
    await _downloadSubscription.cancel();
    await _savedChangesSubscription.cancel();
    await super.close();
  }

  bool get _hasRequestedSync =>
      state.sync is LogsSyncWaiting || state.sync is LogsSyncSyncing;

  /// The status is decided when the event arrives, before any read, because a
  /// queued Sync starts as soon as the Download ends and can finish during it.
  Future<void> _onDownloadProgressed(
    LogsSyncDownloadProgressed event,
    Emitter<LogsSyncState> emit,
  ) async {
    switch (event.progress) {
      case LogsDownloadAdding(:final logEntryCount):
        if (!_hasRequestedSync) {
          emit(
            state.copyWith(
              sync: LogsSync.downloading(logEntryCount: logEntryCount),
            ),
          );
        }
      case LogsDownloadFinished(addedCount: 0):
        await _refresh(emit, endsDownload: true);
      case LogsDownloadFinished(:final addedCount):
        if (!_hasRequestedSync) {
          _newestRead = _readsStarted;
          emit(
            state.copyWith(
              sync: LogsSync.downloaded(logEntryCount: addedCount),
            ),
          );
        }
        final summary = await _readSummary();
        if (summary != null) {
          emit(state.copyWith(unsyncedChanges: _unsyncedChanges(summary)));
        }
    }
  }

  Future<void> _onRequested(
    LogsSyncRequested event,
    Emitter<LogsSyncState> emit,
  ) async {
    if (state.sync.isBusy) {
      return;
    }

    emit(state.copyWith(sync: const LogsSync.waiting()));

    var changeCount = 0;
    try {
      final result = await _logsRepository.syncLogs(
        onProgress: (savedCount, total) {
          changeCount = total;
          emit(
            state.copyWith(
              sync: LogsSync.syncing(
                savedCount: savedCount,
                changeCount: total,
              ),
            ),
          );
        },
      );
      final read = ++_readsStarted;
      final summary = await _logsRepository.getSyncSummary();
      _newestRead = max(_newestRead, read);
      final stillPending = summary.pendingChanges.length;
      final outcome = _syncOutcome(result);
      emit(
        state.copyWith(
          // Changes saved during the sync are still pending, so a full
          // success would overstate what reached the Account.
          sync: stillPending > 0 && outcome is LogsSyncSynced
              ? LogsSync.pending(changeCount: stillPending)
              : outcome,
          unsyncedChanges: _unsyncedChanges(summary),
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      _newestRead = _readsStarted;
      emit(state.copyWith(sync: LogsSync.failed(changeCount: changeCount)));
    }
  }

  /// Re-reads what is pending. A running sync keeps its progress, and so does
  /// a running download unless [endsDownload]; any other state becomes the
  /// pending count or the last sync time.
  Future<void> _refresh(
    Emitter<LogsSyncState> emit, {
    bool endsDownload = false,
  }) async {
    final summary = await _readSummary();
    if (summary == null) {
      return;
    }

    final changeCount = summary.pendingChanges.length;
    emit(
      state.copyWith(
        unsyncedChanges: _unsyncedChanges(summary),
        sync: _hasRequestedSync || (state.sync.isBusy && !endsDownload)
            ? state.sync
            : changeCount == 0
            ? LogsSync.upToDate(lastSyncedAt: summary.lastSyncedAt)
            : LogsSync.pending(changeCount: changeCount),
      ),
    );
  }

  /// Returns null when the read failed, or when a newer read or status has
  /// overtaken it, because there is then nothing to apply.
  Future<LogsSyncSummary?> _readSummary() async {
    final read = ++_readsStarted;
    try {
      final summary = await _logsRepository.getSyncSummary();
      if (read <= _newestRead) {
        return null;
      }
      _newestRead = read;
      return summary;
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return null;
    }
  }

  static LogsSync _syncOutcome(LogsSyncResult result) {
    final LogsSyncResult(:changeCount, :savedCount) = result;

    if (changeCount == 0) {
      return const LogsSync.alreadyUpToDate();
    }
    if (savedCount == changeCount) {
      return LogsSync.synced(changeCount: changeCount);
    }
    if (savedCount > 0) {
      return LogsSync.partial(savedCount: savedCount, changeCount: changeCount);
    }

    return result.onlyNetworkFailures
        ? LogsSync.offline(changeCount: changeCount)
        : LogsSync.failed(changeCount: changeCount);
  }

  /// A deleted log entry has no row to mark, so only created and edited log entries
  /// carry a marker.
  static Map<String, UnsyncedLogEntryChange> _unsyncedChanges(
    LogsSyncSummary summary,
  ) => {
    for (final MapEntry(key: logEntryId, value: change)
        in summary.pendingChanges.entries)
      if (change == PendingLogEntryChange.created)
        logEntryId: UnsyncedLogEntryChange.created
      else if (change == PendingLogEntryChange.updated)
        logEntryId: UnsyncedLogEntryChange.updated,
  };
}
