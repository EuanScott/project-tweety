import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_local.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository_impl.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/fake_session_holder.dart';

void main() {
  group('LogsRepository', () {
    setUpAll(sqfliteFfiInit);

    group('LogsRepositoryImpl', () {
      test('maps datasource log entries to repository values', () async {
        const repository = LogsRepositoryImpl(
          _FakeLogsDataSource(
            logs: [
              LogEntryDto(
                id: 'card-42',
                title: 'Known card',
                description: 'Known description',
              ),
            ],
          ),
          _FixedLogEntryIdGenerator('unused'),
          _UnusedLogsRemoteDataSource(),
        );

        final logs = await repository.getLogs();

        expect(logs, const [
          LogEntry(
            id: 'card-42',
            title: 'Known card',
            description: 'Known description',
          ),
        ]);
      });

      test(
        'maps a datasource log entry lookup to a repository value',
        () async {
          const repository = LogsRepositoryImpl(
            _FakeLogsDataSource(
              logsById: {
                'card-42': LogEntryDto(
                  id: 'card-42',
                  title: 'Known card',
                  description: 'Known description',
                ),
              },
            ),
            _FixedLogEntryIdGenerator('unused'),
            _UnusedLogsRemoteDataSource(),
          );

          final logEntry = await repository.getLogEntryById('card-42');

          expect(
            logEntry,
            const LogEntry(
              id: 'card-42',
              title: 'Known card',
              description: 'Known description',
            ),
          );
        },
      );

      test('preserves a missing datasource log entry lookup', () async {
        const repository = LogsRepositoryImpl(
          _FakeLogsDataSource(),
          _FixedLogEntryIdGenerator('unused'),
          _UnusedLogsRemoteDataSource(),
        );

        final logEntry = await repository.getLogEntryById('missing-card');

        expect(logEntry, isNull);
      });

      test(
        'creates a trimmed log entry with an injected id and returned DTO',
        () async {
          final dataSource = _RecordingLogsDataSource(
            createdLogEntry: const LogEntryDto(
              id: 'generated-id',
              title: 'Trimmed title',
              description: 'Trimmed description',
            ),
          );
          final repository = LogsRepositoryImpl(
            dataSource,
            const _FixedLogEntryIdGenerator('generated-id'),
            const _UnusedLogsRemoteDataSource(),
          );

          final logEntry = await repository.createLogEntry(
            const LogEntryDraft(
              title: '  Trimmed title  ',
              description: '  Trimmed description  ',
            ),
          );

          expect(dataSource.createdDraft?.id, 'generated-id');
          expect(dataSource.createdDraft?.title, 'Trimmed title');
          expect(dataSource.createdDraft?.description, 'Trimmed description');
          expect(
            logEntry,
            const LogEntry(
              id: 'generated-id',
              title: 'Trimmed title',
              description: 'Trimmed description',
            ),
          );
        },
      );

      test('rejects blank trimmed fields without generating an id', () async {
        final idGenerator = _CountingLogEntryIdGenerator();
        final repository = LogsRepositoryImpl(
          const _FakeLogsDataSource(),
          idGenerator,
          const _UnusedLogsRemoteDataSource(),
        );

        await expectLater(
          repository.createLogEntry(
            const LogEntryDraft(title: ' ', description: '\n\t'),
          ),
          throwsA(
            isA<InvalidLogEntryDraftException>().having(
              (exception) => exception.invalidFields,
              'invalid fields',
              {LogEntryDraftField.title, LogEntryDraftField.description},
            ),
          ),
        );
        expect(idGenerator.callCount, 0);
      });

      test('reports a missing update target with its log entry id', () async {
        const repository = LogsRepositoryImpl(
          _MissingUpdateLogsDataSource(),
          _FixedLogEntryIdGenerator('unused'),
          _UnusedLogsRemoteDataSource(),
        );

        await expectLater(
          repository.updateLogEntry(
            logEntryId: 'missing-card',
            draft: const LogEntryDraft(
              title: 'Updated title',
              description: 'Updated description',
            ),
          ),
          throwsA(
            isA<LogEntryNotFoundException>().having(
              (exception) => exception.logEntryId,
              'card id',
              'missing-card',
            ),
          ),
        );
      });
    });

    group('LogsRepositoryImpl with SQLite', () {
      late Directory temporaryDirectory;
      late AppDatabase database;
      late LogsRepository repository;
      late _FakeLogsRemoteDataSource remote;

      setUp(() async {
        temporaryDirectory = await Directory.systemTemp.createTemp(
          'project_tweety_cards_repository_',
        );
        database = SqfliteAppDatabase.test(
          databaseFactory: databaseFactoryFfi,
          databasePath: '${temporaryDirectory.path}/project_tweety.db',
        );
        remote = _FakeLogsRemoteDataSource();
        repository = LogsRepositoryImpl(
          LogsLocalDataSource(database, FakeSessionHolder()),
          const _FixedLogEntryIdGenerator('card-11'),
          remote,
        );
        await database.write((db) {
          return db.insert('cards', <String, Object?>{
            'id': 'card-1',
            'title': 'Card Title 1',
            'description': 'Body of card 1',
            'sync_status': 'synced',
            'updated_at': '2026-07-01T10:00:00.000Z',
            'user_id': FakeSessionHolder().uid,
          });
        });
      });

      tearDown(() async {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      });

      test(
        'creates a log entry that is retrievable through the repository',
        () async {
          const draft = LogEntryDraft(
            title: 'New entry',
            description: 'New card description',
          );

          final logEntry = await repository.createLogEntry(draft);

          expect(await repository.getLogEntryById('card-11'), logEntry);
        },
      );

      test('updates a log entry through the repository', () async {
        const draft = LogEntryDraft(
          title: 'Updated card',
          description: 'Updated card description',
        );

        final logEntry = await repository.updateLogEntry(
          logEntryId: 'card-1',
          draft: draft,
        );

        expect(await repository.getLogEntryById('card-1'), logEntry);
      });

      test('propagates a duplicate generated id from SQLite', () async {
        final duplicateIdRepository = LogsRepositoryImpl(
          LogsLocalDataSource(database, FakeSessionHolder()),
          const _FixedLogEntryIdGenerator('card-1'),
          remote,
        );

        await expectLater(
          duplicateIdRepository.createLogEntry(
            const LogEntryDraft(
              title: 'Duplicate card',
              description: 'Duplicate description',
            ),
          ),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('deletes a log entry through the repository', () async {
        await repository.deleteLogEntry('card-1');

        expect(await repository.getLogEntryById('card-1'), isNull);
      });

      test('deleting a missing log entry succeeds idempotently', () async {
        await repository.deleteLogEntry('missing-card');

        expect(await repository.getLogs(), hasLength(1));
      });

      group('sync', () {
        Future<void> makeThreeChanges() async {
          await repository.createLogEntry(
            const LogEntryDraft(title: 'New', description: 'New'),
          );
          await database.write((db) {
            return db.insert('cards', <String, Object?>{
              'id': 'card-2',
              'title': 'Card Title 2',
              'description': 'Body of card 2',
              'sync_status': 'synced',
              'updated_at': '2026-07-01T10:00:00.000Z',
              'user_id': FakeSessionHolder().uid,
            });
          });
          await repository.updateLogEntry(
            logEntryId: 'card-1',
            draft: const LogEntryDraft(title: 'Edited', description: 'Edited'),
          );
          await repository.deleteLogEntry('card-2');
        }

        test('the summary names each pending change', () async {
          await makeThreeChanges();

          final summary = await repository.getSyncSummary();

          expect(summary.pendingChanges, {
            'card-11': PendingLogEntryChange.created,
            'card-1': PendingLogEntryChange.updated,
            'card-2': PendingLogEntryChange.deleted,
          });
        });

        test('with nothing pending, a sync pushes nothing', () async {
          final result = await repository.syncLogs();

          expect(result, const LogsSyncResult(changeCount: 0, savedCount: 0));
          expect(remote.pushed, isEmpty);
        });

        test('pushes every pending change, reports progress, and leaves '
            'nothing pending', () async {
          await makeThreeChanges();
          final progress = <(int, int)>[];

          final result = await repository.syncLogs(
            onProgress: (saved, total) => progress.add((saved, total)),
          );
          final summary = await repository.getSyncSummary();

          expect(
            remote.pushed.map((logEntry) => logEntry.id),
            unorderedEquals(['card-11', 'card-1', 'card-2']),
          );
          expect(progress, [(0, 3), (1, 3), (2, 3), (3, 3)]);
          expect(result, const LogsSyncResult(changeCount: 3, savedCount: 3));
          expect(summary.pendingChanges, isEmpty);
          expect(summary.lastSyncedAt, isNotNull);
        });

        test('a partial push keeps what failed pending', () async {
          await makeThreeChanges();
          remote.outcomes['card-1'] = LogEntryPushOutcome.failure;

          final result = await repository.syncLogs();
          final summary = await repository.getSyncSummary();

          expect(result, const LogsSyncResult(changeCount: 3, savedCount: 2));
          expect(summary.pendingChanges, {
            'card-1': PendingLogEntryChange.updated,
          });
        });

        test('says when every failure was a network failure', () async {
          await makeThreeChanges();
          for (final id in ['card-11', 'card-1', 'card-2']) {
            remote.outcomes[id] = LogEntryPushOutcome.networkFailure;
          }

          final result = await repository.syncLogs();

          expect(
            result,
            const LogsSyncResult(
              changeCount: 3,
              savedCount: 0,
              onlyNetworkFailures: true,
            ),
          );
          expect((await repository.getSyncSummary()).pendingChanges.length, 3);
        });

        test('a log entry edited while its push is in flight stays '
            'pending', () async {
          await makeThreeChanges();
          remote.whilePushing = () => repository.updateLogEntry(
            logEntryId: 'card-11',
            draft: const LogEntryDraft(
              title: 'Edited again',
              description: 'New',
            ),
          );

          await repository.syncLogs();

          expect((await repository.getSyncSummary()).pendingChanges, {
            'card-11': PendingLogEntryChange.created,
          });
        });
      });
    });
  });
}

class _FakeLogsDataSource implements LogsDataSource {
  const new({this.logs = const [], this.logsById = const {}});

  final List<LogEntryDto> logs;
  final Map<String, LogEntryDto> logsById;

  @override
  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry) async => logEntry;

  @override
  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry) async => logEntry;

  @override
  Future<void> deleteLogEntry(String logEntryId) async {}

  @override
  Future<List<LogEntryDto>> getUnsyncedLogs() async => const [];

  @override
  Future<void> markLogsSynced(List<LogEntryDto> pushedLogs) async {}

  @override
  Future<List<LogEntryDto>> getLogs() async => logs;

  @override
  Future<LogEntryDto?> getLogEntryById(String logEntryId) async =>
      logsById[logEntryId];
}

class _RecordingLogsDataSource extends _FakeLogsDataSource {
  new({required this.createdLogEntry});

  final LogEntryDto createdLogEntry;
  LogEntryDto? createdDraft;

  @override
  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry) async {
    createdDraft = logEntry;
    return createdLogEntry;
  }
}

class _MissingUpdateLogsDataSource extends _FakeLogsDataSource {
  const new();

  @override
  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry) async => null;
}

class _FixedLogEntryIdGenerator implements LogEntryIdGenerator {
  const new(this.value);

  final String value;

  @override
  String generate() => value;
}

class _CountingLogEntryIdGenerator implements LogEntryIdGenerator {
  int callCount = 0;

  @override
  String generate() {
    callCount++;
    return 'generated-$callCount';
  }
}

class const _UnusedLogsRemoteDataSource() implements LogsRemoteDataSource {
  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) => throw UnimplementedError();
}

/// Confirms every log entry unless [outcomes] says otherwise. [whilePushing] runs
/// after the snapshot is taken and before any write settles.
class _FakeLogsRemoteDataSource implements LogsRemoteDataSource {
  final outcomes = <String, LogEntryPushOutcome>{};
  final pushed = <LogEntryDto>[];
  Future<void> Function()? whilePushing;

  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) async {
    await whilePushing?.call();
    pushed.addAll(logs);
    final result = {
      for (final logEntry in logs)
        logEntry.id: outcomes[logEntry.id] ?? LogEntryPushOutcome.confirmed,
    };
    result.forEach(
      (logEntryId, outcome) => onPushed?.call(logEntryId, outcome),
    );

    return result;
  }
}
