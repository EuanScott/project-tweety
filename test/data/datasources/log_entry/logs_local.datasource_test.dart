import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_local.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/fake_session_holder.dart';

void main() {
  group('LogsLocalDataSource', () {
    late Directory temporaryDirectory;
    late AppDatabase database;
    late FakeSessionHolder sessionHolder;
    late LogsLocalDataSource dataSource;

    setUpAll(sqfliteFfiInit);

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'project_tweety_cards_local_datasource_',
      );
      database = SqfliteAppDatabase.test(
        databaseFactory: databaseFactoryFfi,
        databasePath: '${temporaryDirectory.path}/project_tweety.db',
      );
      sessionHolder = FakeSessionHolder(_accountA);
      dataSource = LogsLocalDataSource(database, sessionHolder);
      await _insertRows(database, [
        for (var number = 1; number <= 3; number++) _row(number),
      ]);
    });

    tearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test('returns stored log entries newest first', () async {
      final logs = await dataSource.getLogs();

      expect(logs.map((logEntry) => logEntry.id), <String>[
        'card-3',
        'card-2',
        'card-1',
      ]);
      expect(logs.last.title, 'Card Title 1');
      expect(logs.last.description, 'Body of card 1');
      expect(logs.last.userId, _accountA);
      expect(logs.last.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
    });

    test(
      'orders by when a log entry was created, not when it was stored',
      () async {
        await _insertRows(database, [
          _row(4, createdAt: '2026-06-01T10:00:00.000Z'),
        ]);

        final logs = await dataSource.getLogs();

        expect(logs.last.id, 'card-4');
      },
    );

    test(
      'lists log entries with no creation time last, newest stored first',
      () async {
        await _insertRows(database, [
          _row(4, createdAt: ''),
          _row(5, createdAt: ''),
        ]);

        final logs = await dataSource.getLogs();

        expect(logs.map((logEntry) => logEntry.id), <String>[
          'card-3',
          'card-2',
          'card-1',
          'card-5',
          'card-4',
        ]);
      },
    );

    test(
      'a created log entry is listed before every older log entry',
      () async {
        final createdLogEntry = await dataSource.createLogEntry(
          const LogEntryDto(
            id: 'card-11',
            title: 'New entry',
            description: 'New card description',
          ),
        );

        final logs = await dataSource.getLogs();

        expect(logs.first.id, 'card-11');
        expect(createdLogEntry.createdAt?.isUtc, isTrue);
        expect(createdLogEntry.createdAt, createdLogEntry.updatedAt);
      },
    );

    test('an edit keeps when the log entry was created', () async {
      final updatedLogEntry = await dataSource.updateLogEntry(
        const LogEntryDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );

      final logs = await dataSource.getLogs();

      expect(updatedLogEntry?.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
      expect(logs.last.id, 'card-1');
      expect(logs.last.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
    });

    test('returns a stored log entry by id', () async {
      final logEntry = await dataSource.getLogEntryById('card-3');

      expect(logEntry?.id, 'card-3');
      expect(logEntry?.title, 'Card Title 3');
    });

    test('returns null when a parameterized log entry id is missing', () async {
      final logEntry = await dataSource.getLogEntryById('card-1\' OR 1 = 1 --');

      expect(logEntry, isNull);
    });

    test('hides tombstoned log entries from normal reads', () async {
      await database.write((db) {
        return db.update(
          'cards',
          <String, Object?>{
            'sync_status': 'deleted',
            'deleted_at': '2026-07-10T12:00:00.000Z',
          },
          where: 'id = ?',
          whereArgs: ['card-1'],
        );
      });

      final logs = await dataSource.getLogs();
      final logEntry = await dataSource.getLogEntryById('card-1');

      expect(logs.map((item) => item.id), isNot(contains('card-1')));
      expect(logEntry, isNull);
    });

    test('creates a readable log entry in unsynced created state', () async {
      final createdLogEntry = await dataSource.createLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'New entry',
          description: 'New card description',
        ),
      );

      final storedLogEntry = await dataSource.getLogEntryById('card-11');
      final unsyncedLogs = await dataSource.getUnsyncedLogs();

      expect(storedLogEntry?.title, 'New entry');
      expect(createdLogEntry.id, 'card-11');
      expect(createdLogEntry.syncStatus, LogEntrySyncStatus.created);
      expect(createdLogEntry.updatedAt?.isUtc, isTrue);
      expect(unsyncedLogs.single.id, 'card-11');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.created);
      expect(unsyncedLogs.single.updatedAt?.isUtc, isTrue);
    });

    test(
      'rejects a duplicate log entry id through SQLite constraints',
      () async {
        await expectLater(
          dataSource.createLogEntry(
            const LogEntryDto(
              id: 'card-1',
              title: 'Duplicate card',
              description: 'Duplicate card description',
            ),
          ),
          throwsA(isA<DatabaseException>()),
        );
      },
    );

    test('updates a synced log entry into unsynced updated state', () async {
      final updatedLogEntry = await dataSource.updateLogEntry(
        const LogEntryDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );

      final storedLogEntry = await dataSource.getLogEntryById('card-1');
      final unsyncedLogs = await dataSource.getUnsyncedLogs();

      expect(storedLogEntry?.title, 'Updated card');
      expect(updatedLogEntry?.title, 'Updated card');
      expect(updatedLogEntry?.syncStatus, LogEntrySyncStatus.updated);
      expect(unsyncedLogs.single.id, 'card-1');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.updated);
      expect(unsyncedLogs.single.updatedAt?.isUtc, isTrue);
    });

    test('keeps an updated unsynced log entry in created state', () async {
      await dataSource.createLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'New entry',
          description: 'New card description',
        ),
      );
      await dataSource.updateLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'Updated new card',
          description: 'Updated new card description',
        ),
      );

      final unsyncedLogs = await dataSource.getUnsyncedLogs();

      expect(unsyncedLogs.single.id, 'card-11');
      expect(unsyncedLogs.single.title, 'Updated new card');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.created);
    });

    test('tombstones a synced log entry and hides it from reads', () async {
      await dataSource.deleteLogEntry('card-1');

      final storedLogEntry = await dataSource.getLogEntryById('card-1');
      final logs = await dataSource.getLogs();
      final unsyncedLogs = await dataSource.getUnsyncedLogs();

      expect(storedLogEntry, isNull);
      expect(logs.map((item) => item.id), isNot(contains('card-1')));
      expect(unsyncedLogs.single.id, 'card-1');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.deleted);
      expect(unsyncedLogs.single.deletedAt?.isUtc, isTrue);
    });

    test(
      'does not resurrect a tombstone when a stale update arrives',
      () async {
        await dataSource.deleteLogEntry('card-1');

        final staleUpdate = await dataSource.updateLogEntry(
          const LogEntryDto(
            id: 'card-1',
            title: 'Stale update',
            description: 'Must not cancel the pending delete',
          ),
        );

        final unsyncedLogs = await dataSource.getUnsyncedLogs();

        expect(await dataSource.getLogEntryById('card-1'), isNull);
        expect(staleUpdate, isNull);
        expect(unsyncedLogs.single.id, 'card-1');
        expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.deleted);
        expect(unsyncedLogs.single.title, 'Card Title 1');
      },
    );

    test('physically removes a deleted unsynced log entry', () async {
      await dataSource.createLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'New entry',
          description: 'New card description',
        ),
      );

      await dataSource.deleteLogEntry('card-11');

      expect(await dataSource.getLogEntryById('card-11'), isNull);
      expect(await dataSource.getUnsyncedLogs(), isEmpty);
    });

    test(
      'treats deleting a missing log entry as an idempotent success',
      () async {
        await dataSource.deleteLogEntry('missing-card');

        expect(await dataSource.getLogs(), hasLength(3));
        expect(await dataSource.getUnsyncedLogs(), isEmpty);
      },
    );

    test('marks uploaded changes synced and removes tombstones', () async {
      await dataSource.createLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'New entry',
          description: 'New card description',
        ),
      );
      await dataSource.updateLogEntry(
        const LogEntryDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );
      await dataSource.deleteLogEntry('card-2');

      await dataSource.markLogsSynced(await dataSource.getUnsyncedLogs());

      final createdLogEntry = await dataSource.getLogEntryById('card-11');
      final updatedLogEntry = await dataSource.getLogEntryById('card-1');

      expect(await dataSource.getUnsyncedLogs(), isEmpty);
      expect(createdLogEntry?.syncStatus, LogEntrySyncStatus.synced);
      expect(createdLogEntry?.lastSyncedAt?.isUtc, isTrue);
      expect(updatedLogEntry?.syncStatus, LogEntrySyncStatus.synced);
      expect(updatedLogEntry?.lastSyncedAt?.isUtc, isTrue);
      expect(await dataSource.getLogEntryById('card-2'), isNull);
    });

    test('keeps a log entry dirty when it was edited after the push '
        'snapshot', () async {
      await dataSource.createLogEntry(
        const LogEntryDto(id: 'card-11', title: 'New', description: 'New'),
      );
      await dataSource.deleteLogEntry('card-2');
      final snapshot = await dataSource.getUnsyncedLogs();

      await dataSource.updateLogEntry(
        const LogEntryDto(id: 'card-11', title: 'Edited', description: 'New'),
      );
      await dataSource.markLogsSynced(snapshot);

      final unsyncedLogs = await dataSource.getUnsyncedLogs();
      expect(unsyncedLogs.single.id, 'card-11');
      expect(unsyncedLogs.single.title, 'Edited');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.created);
      expect(await dataSource.getLogEntryById('card-2'), isNull);
    });

    test('a new log entry deleted while its first push is in flight is '
        'tombstoned, so the next sync removes its copy', () async {
      await dataSource.createLogEntry(
        const LogEntryDto(id: 'card-11', title: 'New', description: 'New'),
      );
      final snapshot = await dataSource.getUnsyncedLogs();

      await dataSource.deleteLogEntry('card-11');
      await dataSource.markLogsSynced(snapshot);

      final unsyncedLogs = await dataSource.getUnsyncedLogs();
      expect(unsyncedLogs.single.id, 'card-11');
      expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.deleted);
      expect(await dataSource.getLogs(), hasLength(3));
    });

    group('a row with an unknown status and deleted_at set', () {
      setUp(() async {
        await _insertRows(database, [
          {
            ..._row(4, status: 'garbage'),
            'deleted_at': '2026-07-02T10:00:00.000Z',
          },
        ]);
      });

      test('is hidden from reads, like any tombstone', () async {
        final logs = await dataSource.getLogs();

        expect(logs.map((item) => item.id), isNot(contains('card-4')));
        expect(await dataSource.getLogEntryById('card-4'), isNull);
      });

      test('is pushed as a delete and then purged', () async {
        final pending = await dataSource.getUnsyncedLogs();
        expect(pending.single.syncStatus, LogEntrySyncStatus.deleted);

        await dataSource.markLogsSynced(pending);

        expect(await dataSource.getUnsyncedLogs(), isEmpty);
        expect(
          (await _rawRows(database)).map((row) => row['id']),
          isNot(contains('card-4')),
        );
      });
    });

    test('a known live status with deleted_at set is still a tombstone, '
        'read and pushed as a delete', () async {
      await _insertRows(database, [
        {..._row(4), 'deleted_at': '2026-07-02T10:00:00.000Z'},
      ]);

      expect(await dataSource.getLogEntryById('card-4'), isNull);
      final pending = await dataSource.getUnsyncedLogs();
      expect(pending.single.syncStatus, LogEntrySyncStatus.deleted);

      await dataSource.markLogsSynced(pending);

      expect(await dataSource.getUnsyncedLogs(), isEmpty);
    });

    test('accepts an empty uploaded log entry batch', () async {
      await dataSource.markLogsSynced(const []);

      expect(await dataSource.getUnsyncedLogs(), isEmpty);
    });

    group('ownership', () {
      setUp(() async {
        await _insertRows(database, [
          _row(4, userId: _accountB),
          _row(5, userId: _accountB, status: 'updated'),
        ]);
      });

      test("reads never return another Account's log entries", () async {
        expect(
          (await dataSource.getLogs()).map((logEntry) => logEntry.id),
          isNot(anyOf(contains('card-4'), contains('card-5'))),
        );
        expect(await dataSource.getLogEntryById('card-4'), isNull);
        expect(await dataSource.getUnsyncedLogs(), isEmpty);
      });

      test("writes never change another Account's log entries", () async {
        final before = await _rawRows(database);

        final updated = await dataSource.updateLogEntry(
          const LogEntryDto(id: 'card-4', title: 'Taken', description: 'Taken'),
        );
        await dataSource.deleteLogEntry('card-4');
        await dataSource.markLogsSynced([
          LogEntryDto.fromDatabaseRow(
            _row(5, userId: _accountB, status: 'updated'),
          ),
        ]);

        expect(updated, isNull);
        expect(await _rawRows(database), before);
      });

      test('a created log entry belongs to the signed-in Account', () async {
        await dataSource.createLogEntry(
          const LogEntryDto(id: 'card-11', title: 'New', description: 'New'),
        );

        expect(
          (await _rawRows(database)).last,
          allOf(
            containsPair('id', 'card-11'),
            containsPair('user_id', _accountA),
          ),
        );
      });

      test('every operation throws when nobody is signed in', () async {
        sessionHolder.signedInUid = null;

        await expectLater(
          dataSource.getLogs(),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.getLogEntryById('card-1'),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.createLogEntry(
            const LogEntryDto(id: 'card-11', title: 'New', description: 'New'),
          ),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.updateLogEntry(
            const LogEntryDto(id: 'card-1', title: 'Edit', description: 'Edit'),
          ),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.deleteLogEntry('card-1'),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.getUnsyncedLogs(),
          throwsA(isA<AccountNotSignedInException>()),
        );
        await expectLater(
          dataSource.markLogsSynced([LogEntryDto.fromDatabaseRow(_row(1))]),
          throwsA(isA<AccountNotSignedInException>()),
        );
      });
    });

    group('download', () {
      LogEntryDto downloaded(
        int number, {
        String title = 'Remote title',
        DateTime? updatedAt,
        String userId = _accountA,
      }) => LogEntryDto(
        id: 'card-$number',
        title: title,
        description: 'Remote body',
        createdAt: DateTime.utc(2026, 8, 1),
        updatedAt: updatedAt ?? DateTime.utc(2026, 8, 2),
        userId: userId,
      );

      test('adds a missing log entry as synced and owned by the Account, '
          'with its text and times from the document', () async {
        final before = DateTime.now().toUtc();

        final added = await dataSource.addDownloadedLogs([downloaded(4)]);

        final row = (await _rawRows(database)).last;
        expect(added, 1);
        expect(row, containsPair('id', 'card-4'));
        expect(row, containsPair('title', 'Remote title'));
        expect(row, containsPair('description', 'Remote body'));
        expect(row, containsPair('sync_status', 'synced'));
        expect(row, containsPair('user_id', _accountA));
        expect(row, containsPair('created_at', '2026-08-01T00:00:00.000Z'));
        expect(row, containsPair('updated_at', '2026-08-02T00:00:00.000Z'));
        expect(row, containsPair('deleted_at', null));
        final lastSyncedAt = DateTime.parse(row['last_synced_at']! as String);
        expect(lastSyncedAt.isBefore(before), isFalse);
        expect(
          (await dataSource.getLogs()).map((logEntry) => logEntry.id),
          contains('card-4'),
        );
      });

      test('never changes a row the device already holds, whatever its '
          'state or owner', () async {
        await _insertRows(database, [
          _row(4, status: 'created', lastSyncedAt: null),
          _row(5, status: 'updated'),
          _row(6, status: 'deleted'),
          _row(7, userId: _accountB),
        ]);
        final before = await _rawRows(database);

        final added = await dataSource.addDownloadedLogs([
          // card-1 is synced locally; a newer remote copy still loses.
          downloaded(1, updatedAt: DateTime.utc(2027)),
          for (var number = 4; number <= 7; number++) downloaded(number),
        ]);

        expect(added, 0);
        expect(await _rawRows(database), before);
      });

      test('adds the oldest change first', () async {
        await dataSource.addDownloadedLogs([
          downloaded(4, updatedAt: DateTime.utc(2026, 9, 3)),
          downloaded(5, updatedAt: DateTime.utc(2026, 9, 1)),
          downloaded(6, updatedAt: DateTime.utc(2026, 9, 2)),
        ]);

        expect((await _rawRows(database)).skip(3).map((row) => row['id']), [
          'card-5',
          'card-6',
          'card-4',
        ]);
      });

      test('adds nothing when the Session changed since the read', () async {
        final before = await _rawRows(database);

        await expectLater(
          dataSource.addDownloadedLogs([
            downloaded(4),
            downloaded(5, userId: _accountB),
          ]),
          throwsA(isA<AccountNotSignedInException>()),
        );
        expect(await _rawRows(database), before);
      });
    });

    group('adoption', () {
      setUp(() async {
        await _insertRows(database, [
          _row(6, userId: null),
          _row(7, userId: null, status: 'updated'),
          _row(8, userId: null, status: 'created', lastSyncedAt: null),
          _row(9, userId: null, status: 'deleted'),
          {
            ..._row(10, userId: null, status: 'garbage'),
            'deleted_at': '2026-07-02T10:00:00.000Z',
          },
        ]);
      });

      test('an unowned tombstone with an unknown status is dropped, '
          'not adopted', () async {
        await dataSource.getLogs();

        expect(
          (await _rawRows(database)).map((row) => row['id']),
          isNot(contains('card-10')),
        );
      });

      test(
        'the first read adopts unowned log entries as never synced',
        () async {
          final logs = await dataSource.getLogs();
          final rows = {
            for (final row in await _rawRows(database)) row['id']: row,
          };

          expect(
            logs.map((logEntry) => logEntry.id),
            containsAll(<String>['card-6', 'card-7', 'card-8']),
          );
          expect(rows['card-6'], {
            ..._row(
              6,
              userId: _accountA,
              status: 'created',
              lastSyncedAt: null,
            ),
          });
          expect(rows['card-7'], {
            ..._row(
              7,
              userId: _accountA,
              status: 'created',
              lastSyncedAt: null,
            ),
          });
          expect(rows['card-8'], {
            ..._row(
              8,
              userId: _accountA,
              status: 'created',
              lastSyncedAt: null,
            ),
          });
          expect(rows, isNot(contains('card-9')));
        },
      );

      test(
        'the first write adopts unowned log entries before it runs',
        () async {
          await dataSource.deleteLogEntry('card-6');

          final rows = await _rawRows(database);

          expect(rows.map((row) => row['user_id']), everyElement(_accountA));
          expect(rows.map((row) => row['id']), isNot(contains('card-6')));
        },
      );

      test('adopted log entries are pushed by the next sync', () async {
        expect(
          (await dataSource.getUnsyncedLogs()).map((logEntry) => logEntry.id),
          <String>['card-6', 'card-7', 'card-8'],
        );
      });

      test('a later Account adopts nothing the first one took', () async {
        await dataSource.getLogs();
        sessionHolder.signedInUid = _accountB;

        expect(await dataSource.getLogs(), isEmpty);
        expect(
          (await _rawRows(database)).map((row) => row['user_id']),
          everyElement(_accountA),
        );
      });
    });
  });
}

const _accountA = 'account-a';
const _accountB = 'account-b';

Map<String, Object?> _row(
  int number, {
  String? userId = _accountA,
  String status = 'synced',
  String? lastSyncedAt = '2026-07-01T12:00:00.000Z',
  String? createdAt,
}) => <String, Object?>{
  'id': 'card-$number',
  'title': 'Card Title $number',
  'description': 'Body of card $number',
  'sync_status': status,
  'updated_at': '2026-07-01T10:00:00.000Z',
  'last_synced_at': lastSyncedAt,
  'deleted_at': status == 'deleted' ? '2026-07-02T10:00:00.000Z' : null,
  'user_id': userId,
  'created_at':
      createdAt ?? '2026-07-01T10:${number.toString().padLeft(2, '0')}:00.000Z',
};

Future<void> _insertRows(
  AppDatabase database,
  List<Map<String, Object?>> rows,
) {
  return database.write((db) async {
    for (final row in rows) {
      await db.insert('cards', row);
    }
  });
}

Future<List<Map<String, Object?>>> _rawRows(AppDatabase database) {
  return database.read((db) => db.query('cards', orderBy: 'rowid ASC'));
}
