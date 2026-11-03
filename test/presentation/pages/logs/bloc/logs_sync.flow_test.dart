import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_local.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository_impl.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs.bloc.dart';
import 'package:project_tweety/presentation/pages/logs/bloc/logs_sync.bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../support/fake_session_holder.dart';

/// The Sync row over the real repository and real SQLite, where the order of a
/// Sync and a Download comes from the repository's queue and not from a fake.
void main() {
  setUpAll(sqfliteFfiInit);

  late Directory directory;
  late AppDatabase database;
  late _ControllableRemoteDataSource remote;
  late LogsRepositoryImpl repository;
  late LogsBloc logsBloc;
  late LogsSyncBloc bloc;
  late List<LogsSync> syncs;
  late StreamSubscription<LogsSync> syncsSubscription;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('logs_sync_flow_');
    database = SqfliteAppDatabase.test(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${directory.path}/logs.db',
    );
    remote = _ControllableRemoteDataSource();
    repository = LogsRepositoryImpl(
      LogsLocalDataSource(database, FakeSessionHolder()),
      const _FixedLogEntryIdGenerator(),
      remote,
    );
    await database.write(
      (db) => db.insert('cards', <String, Object?>{
        'id': 'card-1',
        'title': 'Title',
        'description': 'Description',
        'sync_status': 'synced',
        'updated_at': '2026-07-01T10:00:00.000Z',
        'user_id': FakeSessionHolder().uid,
      }),
    );

    logsBloc = LogsBloc(repository);
    bloc = LogsSyncBloc(repository);
    syncs = [];
    syncsSubscription = bloc.stream
        .map((state) => state.sync)
        .distinct()
        .listen(syncs.add);
  });

  tearDown(() async {
    await syncsSubscription.cancel();
    await bloc.close();
    await logsBloc.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<void> savePendingChange() => repository.updateLogEntry(
    logEntryId: 'card-1',
    draft: const LogEntryDraft(title: 'Edited', description: 'Description'),
  );

  /// Queues a Sync behind a running Download, and then lets the Download end.
  Future<void> startSyncDuringDownload() async {
    unawaited(repository.downloadLogs());
    await _until(() => remote.fetchCount == 1);
    bloc.add(const LogsSyncRequested());
    await _until(() => bloc.state.sync is LogsSyncWaiting);
    remote.fetchGate.complete();
  }

  group('a Sync asked for during a Download', () {
    test('keeps the row busy while the push is held open', () async {
      await savePendingChange();
      remote.pushGate = Completer<void>();

      await startSyncDuringDownload();
      await _until(() => remote.isPushing);
      await _letLateWritesLand();

      expect(bloc.state.sync.isBusy, isTrue);
      expect(bloc.state.sync, isNot(isA<LogsSyncDownloaded>()));

      remote.pushGate!.complete();
      await _until(() => bloc.state.sync is LogsSyncSynced);
      expect(syncs, isNot(contains(isA<LogsSyncDownloaded>())));
    });

    test('never shows the Download when the push is fast', () async {
      await savePendingChange();

      await startSyncDuringDownload();
      await _until(() => syncs.contains(const LogsSync.synced(changeCount: 1)));
      await _letLateWritesLand();

      expect(syncs, isNot(contains(isA<LogsSyncDownloaded>())));
      expect(bloc.state.sync, const LogsSync.synced(changeCount: 1));
    });

    test('keeps its result when nothing was pending', () async {
      await startSyncDuringDownload();
      await _until(() => syncs.contains(const LogsSync.alreadyUpToDate()));
      await _letLateWritesLand();

      expect(syncs, isNot(contains(isA<LogsSyncDownloaded>())));
      expect(bloc.state.sync, const LogsSync.alreadyUpToDate());
    });

    test('still adds the downloaded log entries to the list', () async {
      logsBloc.add(const LogsStarted());
      await _until(() => logsBloc.state.items.length == 1);

      await startSyncDuringDownload();
      await _until(() => logsBloc.state.items.length == 2);

      expect(logsBloc.state.items.map((item) => item.id), contains('remote-1'));
    });
  });

  test('a Download with no Sync shows downloading, then downloaded', () async {
    remote.fetchGate.complete();

    await repository.downloadLogs();
    await _until(() => bloc.state.sync is LogsSyncDownloaded);

    expect(syncs, const [
      LogsSync.downloading(logEntryCount: 1),
      LogsSync.downloaded(logEntryCount: 1),
    ]);
  });
}

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 500 && !condition(); attempt += 1) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
  expect(condition(), isTrue, reason: 'The condition never held.');
}

/// A stale write comes from a real SQLite read, so only real time lets it land.
Future<void> _letLateWritesLand() =>
    Future<void>.delayed(const Duration(milliseconds: 100));

class const _FixedLogEntryIdGenerator() implements LogEntryIdGenerator {
  @override
  String generate() => 'unused';
}

/// Holds the server read until [fetchGate] completes, and the push until
/// [pushGate] completes when that is set. The server always holds one log entry
/// that the device does not.
class _ControllableRemoteDataSource implements LogsRemoteDataSource {
  final fetchGate = Completer<void>();
  Completer<void>? pushGate;
  var fetchCount = 0;
  var isPushing = false;

  @override
  Future<List<LogEntryDto>> fetchLogs() async {
    fetchCount += 1;
    await fetchGate.future;

    return [
      LogEntryDto(
        id: 'remote-1',
        title: 'Remote',
        description: 'From another device',
        createdAt: DateTime.utc(2026, 8),
        updatedAt: DateTime.utc(2026, 8, 2),
        userId: FakeSessionHolder().uid,
      ),
    ];
  }

  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) async {
    isPushing = true;
    await pushGate?.future;
    for (final logEntry in logs) {
      onPushed?.call(logEntry.id, LogEntryPushOutcome.confirmed);
    }

    return {
      for (final logEntry in logs) logEntry.id: LogEntryPushOutcome.confirmed,
    };
  }
}
