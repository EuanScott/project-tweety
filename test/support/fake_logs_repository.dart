import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

/// In-memory [LogsRepository] used across widget and bloc tests.
///
/// The default constructor is a working repository backed by a mutable list.
/// Every operation records a call count, and any operation can be made to fail
/// by passing the matching error. The two named constructors cover the cases
/// that cannot be expressed that way: a collection-only repository whose detail
/// reads are a tripwire, and a gated repository whose writes stay pending until
/// the test completes them.
class FakeLogsRepository implements LogsRepository {
  new({
    List<LogEntry>? logs,
    this.readError,
    this.createError,
    this.updateError,
    this.deleteError,
  }) : _logs = List<LogEntry>.of(logs ?? sampleLogs),
       _readLogs = null,
       _detailReadsSupported = true,
       _gateWrites = false;

  /// Reads the collection through [readLogs] and treats any detail read as a
  /// failure, for tests asserting that details derive from the loaded
  /// collection rather than a second round trip.
  new collectionOnly(Future<List<LogEntry>> Function() readLogs)
    : _logs = <LogEntry>[],
      _readLogs = readLogs,
      _detailReadsSupported = false,
      _gateWrites = false,
      readError = null,
      createError = null,
      updateError = null,
      deleteError = null;

  /// Leaves every write pending until [completeCreate], [completeUpdate], or
  /// [completeDelete] is called, so tests can assert in-flight state. Pass
  /// [logs] when the in-flight write is an update or a delete, which needs a
  /// log entry to already exist.
  new gated({List<LogEntry>? logs})
    : _logs = List<LogEntry>.of(logs ?? const <LogEntry>[]),
      _readLogs = null,
      _detailReadsSupported = true,
      _gateWrites = true,
      readError = null,
      createError = null,
      updateError = null,
      deleteError = null;

  final List<LogEntry> _logs;
  final Future<List<LogEntry>> Function()? _readLogs;
  final bool _detailReadsSupported;
  final bool _gateWrites;

  final Object? readError;
  final Object? createError;
  final Object? updateError;
  final Object? deleteError;

  /// What [getSyncSummary] returns. [syncLogs] replaces it with
  /// [summaryAfterSync] when that is set, as a real push would.
  LogsSyncSummary syncSummary = const LogsSyncSummary();
  LogsSyncSummary? summaryAfterSync;

  /// What [syncLogs] returns, after reporting no progress and then each of
  /// [syncProgress] against its change count.
  LogsSyncResult syncResult = const LogsSyncResult(
    changeCount: 0,
    savedCount: 0,
  );
  List<int> syncProgress = const [];
  Object? syncError;

  /// Holds [syncLogs] open until completed, to assert in-flight state.
  Completer<void>? pendingSync;
  var syncRequestCount = 0;

  var collectionReadCount = 0;
  var detailReadCount = 0;
  var createRequestCount = 0;
  var updateRequestCount = 0;
  var deleteRequestCount = 0;

  final Completer<LogEntry> _createCompleter = Completer<LogEntry>();
  final Completer<LogEntry> _updateCompleter = Completer<LogEntry>();
  final Completer<void> _deleteCompleter = Completer<void>();

  List<LogEntry> get logs => List<LogEntry>.unmodifiable(_logs);

  @override
  Future<List<LogEntry>> getLogs() {
    collectionReadCount += 1;

    final readLogs = _readLogs;
    if (readLogs != null) {
      return readLogs();
    }

    final error = readError;
    if (error != null) {
      return Future<List<LogEntry>>.error(error);
    }

    return Future<List<LogEntry>>.value(List<LogEntry>.of(_logs));
  }

  @override
  Future<LogEntry?> getLogEntryById(String logEntryId) async {
    detailReadCount += 1;

    if (!_detailReadsSupported) {
      throw UnsupportedError('Details must derive from the loaded collection.');
    }

    for (final logEntry in _logs) {
      if (logEntry.id == logEntryId) {
        return logEntry;
      }
    }

    return null;
  }

  @override
  Future<LogEntry> createLogEntry(LogEntryDraft draft) {
    createRequestCount += 1;

    final error = createError;
    if (error != null) {
      return Future<LogEntry>.error(error);
    }

    if (_gateWrites) {
      return _createCompleter.future;
    }

    final logEntry = LogEntry(
      id: 'created-card',
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
    _logs.insert(0, logEntry);

    return Future<LogEntry>.value(logEntry);
  }

  void completeCreate([LogEntry? logEntry]) {
    _createCompleter.complete(
      logEntry ??
          const LogEntry(
            id: 'created-card',
            title: 'New title',
            description: 'New description',
          ),
    );
  }

  @override
  Future<LogEntry> updateLogEntry({
    required String logEntryId,
    required LogEntryDraft draft,
  }) {
    updateRequestCount += 1;

    final error = updateError;
    if (error != null) {
      return Future<LogEntry>.error(error);
    }

    if (_gateWrites) {
      return _updateCompleter.future;
    }

    final logEntry = LogEntry(
      id: logEntryId,
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
    final index = _logs.indexWhere((existing) => existing.id == logEntryId);
    if (index >= 0) {
      _logs[index] = logEntry;
    }

    return Future<LogEntry>.value(logEntry);
  }

  void completeUpdate(LogEntry logEntry) => _updateCompleter.complete(logEntry);

  @override
  Future<void> deleteLogEntry(String logEntryId) {
    deleteRequestCount += 1;

    final error = deleteError;
    if (error != null) {
      return Future<void>.error(error);
    }

    if (_gateWrites) {
      return _deleteCompleter.future;
    }

    _logs.removeWhere((logEntry) => logEntry.id == logEntryId);

    return Future<void>.value();
  }

  void completeDelete() => _deleteCompleter.complete();

  @override
  Future<LogsSyncSummary> getSyncSummary() async => syncSummary;

  @override
  Future<LogsSyncResult> syncLogs({
    void Function(int savedCount, int changeCount)? onProgress,
  }) async {
    syncRequestCount += 1;
    final changeCount = syncResult.changeCount;
    if (changeCount > 0) {
      onProgress?.call(0, changeCount);
    }
    await pendingSync?.future;

    if (syncError case final error?) {
      throw error;
    }

    for (final savedCount in syncProgress) {
      onProgress?.call(savedCount, changeCount);
    }
    syncSummary = summaryAfterSync ?? syncSummary;

    return syncResult;
  }

  /// The ten log entries the app ships with, shared by every test that needs a
  /// populated list.
  static final List<LogEntry> sampleLogs = List<LogEntry>.generate(
    10,
    (index) => LogEntry(
      id: 'card-${index + 1}',
      title: 'Card Title ${index + 1}',
      description:
          'This is the body copy for card number ${index + 1}. '
          'You can replace this with whatever description you want.',
    ),
    growable: false,
  );
}

/// Swaps the registered [LogsRepository] for [repository].
///
/// Only meaningful for tests that drive `MyApp`, which resolves its own
/// dependencies from `GetIt`.
void replaceLogsRepository(LogsRepository repository) {
  GetIt.I
    // GetIt.unregister returns FutureOr and completes synchronously here:
    // the fakes register no async disposers, so there is no future to await.
    // ignore: discarded_futures
    ..unregister<LogsRepository>()
    ..registerLazySingleton<LogsRepository>(() => repository);
}
