import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../support/fake_session_holder.dart';

void main() {
  group('CardsLocalDataSource', () {
    late Directory temporaryDirectory;
    late AppDatabase database;
    late FakeSessionHolder sessionHolder;
    late CardsLocalDataSource dataSource;

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
      dataSource = CardsLocalDataSource(database, sessionHolder);
      await _insertRows(database, [
        for (var number = 1; number <= 3; number++) _row(number),
      ]);
    });

    tearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test('returns stored cards newest first', () async {
      final cards = await dataSource.getCards();

      expect(cards.map((card) => card.id), <String>[
        'card-3',
        'card-2',
        'card-1',
      ]);
      expect(cards.last.title, 'Card Title 1');
      expect(cards.last.description, 'Body of card 1');
      expect(cards.last.userId, _accountA);
      expect(cards.last.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
    });

    test('orders by when a Card was created, not when it was stored', () async {
      await _insertRows(database, [
        _row(4, createdAt: '2026-06-01T10:00:00.000Z'),
      ]);

      final cards = await dataSource.getCards();

      expect(cards.last.id, 'card-4');
    });

    test(
      'lists Cards with no creation time last, newest stored first',
      () async {
        await _insertRows(database, [
          _row(4, createdAt: ''),
          _row(5, createdAt: ''),
        ]);

        final cards = await dataSource.getCards();

        expect(cards.map((card) => card.id), <String>[
          'card-3',
          'card-2',
          'card-1',
          'card-5',
          'card-4',
        ]);
      },
    );

    test('a created Card is listed before every older Card', () async {
      final createdCard = await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );

      final cards = await dataSource.getCards();

      expect(cards.first.id, 'card-11');
      expect(createdCard.createdAt?.isUtc, isTrue);
      expect(createdCard.createdAt, createdCard.updatedAt);
    });

    test('an edit keeps when the Card was created', () async {
      final updatedCard = await dataSource.updateCard(
        const CardDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );

      final cards = await dataSource.getCards();

      expect(updatedCard?.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
      expect(cards.last.id, 'card-1');
      expect(cards.last.createdAt, DateTime.utc(2026, 7, 1, 10, 1));
    });

    test('returns a stored card by id', () async {
      final card = await dataSource.getCardById('card-3');

      expect(card?.id, 'card-3');
      expect(card?.title, 'Card Title 3');
    });

    test('returns null when a parameterized card id is missing', () async {
      final card = await dataSource.getCardById('card-1\' OR 1 = 1 --');

      expect(card, isNull);
    });

    test('hides tombstoned cards from normal reads', () async {
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

      final cards = await dataSource.getCards();
      final card = await dataSource.getCardById('card-1');

      expect(cards.map((item) => item.id), isNot(contains('card-1')));
      expect(card, isNull);
    });

    test('creates a readable card in unsynced created state', () async {
      final createdCard = await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );

      final storedCard = await dataSource.getCardById('card-11');
      final unsyncedCards = await dataSource.getUnsyncedCards();

      expect(storedCard?.title, 'New card');
      expect(createdCard.id, 'card-11');
      expect(createdCard.syncStatus, CardSyncStatus.created);
      expect(createdCard.updatedAt?.isUtc, isTrue);
      expect(unsyncedCards.single.id, 'card-11');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.created);
      expect(unsyncedCards.single.updatedAt?.isUtc, isTrue);
    });

    test('rejects a duplicate card id through SQLite constraints', () async {
      await expectLater(
        dataSource.createCard(
          const CardDto(
            id: 'card-1',
            title: 'Duplicate card',
            description: 'Duplicate card description',
          ),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('updates a synced card into unsynced updated state', () async {
      final updatedCard = await dataSource.updateCard(
        const CardDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );

      final storedCard = await dataSource.getCardById('card-1');
      final unsyncedCards = await dataSource.getUnsyncedCards();

      expect(storedCard?.title, 'Updated card');
      expect(updatedCard?.title, 'Updated card');
      expect(updatedCard?.syncStatus, CardSyncStatus.updated);
      expect(unsyncedCards.single.id, 'card-1');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.updated);
      expect(unsyncedCards.single.updatedAt?.isUtc, isTrue);
    });

    test('keeps an updated unsynced card in created state', () async {
      await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );
      await dataSource.updateCard(
        const CardDto(
          id: 'card-11',
          title: 'Updated new card',
          description: 'Updated new card description',
        ),
      );

      final unsyncedCards = await dataSource.getUnsyncedCards();

      expect(unsyncedCards.single.id, 'card-11');
      expect(unsyncedCards.single.title, 'Updated new card');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.created);
    });

    test('tombstones a synced card and hides it from reads', () async {
      await dataSource.deleteCard('card-1');

      final storedCard = await dataSource.getCardById('card-1');
      final cards = await dataSource.getCards();
      final unsyncedCards = await dataSource.getUnsyncedCards();

      expect(storedCard, isNull);
      expect(cards.map((item) => item.id), isNot(contains('card-1')));
      expect(unsyncedCards.single.id, 'card-1');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.deleted);
      expect(unsyncedCards.single.deletedAt?.isUtc, isTrue);
    });

    test(
      'does not resurrect a tombstone when a stale update arrives',
      () async {
        await dataSource.deleteCard('card-1');

        final staleUpdate = await dataSource.updateCard(
          const CardDto(
            id: 'card-1',
            title: 'Stale update',
            description: 'Must not cancel the pending delete',
          ),
        );

        final unsyncedCards = await dataSource.getUnsyncedCards();

        expect(await dataSource.getCardById('card-1'), isNull);
        expect(staleUpdate, isNull);
        expect(unsyncedCards.single.id, 'card-1');
        expect(unsyncedCards.single.syncStatus, CardSyncStatus.deleted);
        expect(unsyncedCards.single.title, 'Card Title 1');
      },
    );

    test('physically removes a deleted unsynced card', () async {
      await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );

      await dataSource.deleteCard('card-11');

      expect(await dataSource.getCardById('card-11'), isNull);
      expect(await dataSource.getUnsyncedCards(), isEmpty);
    });

    test('treats deleting a missing card as an idempotent success', () async {
      await dataSource.deleteCard('missing-card');

      expect(await dataSource.getCards(), hasLength(3));
      expect(await dataSource.getUnsyncedCards(), isEmpty);
    });

    test('marks uploaded changes synced and removes tombstones', () async {
      await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );
      await dataSource.updateCard(
        const CardDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );
      await dataSource.deleteCard('card-2');

      await dataSource.markCardsSynced(await dataSource.getUnsyncedCards());

      final createdCard = await dataSource.getCardById('card-11');
      final updatedCard = await dataSource.getCardById('card-1');

      expect(await dataSource.getUnsyncedCards(), isEmpty);
      expect(createdCard?.syncStatus, CardSyncStatus.synced);
      expect(createdCard?.lastSyncedAt?.isUtc, isTrue);
      expect(updatedCard?.syncStatus, CardSyncStatus.synced);
      expect(updatedCard?.lastSyncedAt?.isUtc, isTrue);
      expect(await dataSource.getCardById('card-2'), isNull);
    });

    test('keeps a Card dirty when it was edited after the push '
        'snapshot', () async {
      await dataSource.createCard(
        const CardDto(id: 'card-11', title: 'New', description: 'New'),
      );
      await dataSource.deleteCard('card-2');
      final snapshot = await dataSource.getUnsyncedCards();

      await dataSource.updateCard(
        const CardDto(id: 'card-11', title: 'Edited', description: 'New'),
      );
      await dataSource.markCardsSynced(snapshot);

      final unsyncedCards = await dataSource.getUnsyncedCards();
      expect(unsyncedCards.single.id, 'card-11');
      expect(unsyncedCards.single.title, 'Edited');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.created);
      expect(await dataSource.getCardById('card-2'), isNull);
    });

    test('a new Card deleted while its first push is in flight is '
        'tombstoned, so the next sync removes its copy', () async {
      await dataSource.createCard(
        const CardDto(id: 'card-11', title: 'New', description: 'New'),
      );
      final snapshot = await dataSource.getUnsyncedCards();

      await dataSource.deleteCard('card-11');
      await dataSource.markCardsSynced(snapshot);

      final unsyncedCards = await dataSource.getUnsyncedCards();
      expect(unsyncedCards.single.id, 'card-11');
      expect(unsyncedCards.single.syncStatus, CardSyncStatus.deleted);
      expect(await dataSource.getCards(), hasLength(3));
    });

    test('accepts an empty uploaded card batch', () async {
      await dataSource.markCardsSynced(const []);

      expect(await dataSource.getUnsyncedCards(), isEmpty);
    });

    group('ownership', () {
      setUp(() async {
        await _insertRows(database, [
          _row(4, userId: _accountB),
          _row(5, userId: _accountB, status: 'updated'),
        ]);
      });

      test("reads never return another Account's Cards", () async {
        expect(
          (await dataSource.getCards()).map((card) => card.id),
          isNot(anyOf(contains('card-4'), contains('card-5'))),
        );
        expect(await dataSource.getCardById('card-4'), isNull);
        expect(await dataSource.getUnsyncedCards(), isEmpty);
      });

      test("writes never change another Account's Cards", () async {
        final before = await _rawRows(database);

        final updated = await dataSource.updateCard(
          const CardDto(id: 'card-4', title: 'Taken', description: 'Taken'),
        );
        await dataSource.deleteCard('card-4');
        await dataSource.markCardsSynced([
          CardDto.fromDatabaseRow(
            _row(5, userId: _accountB, status: 'updated'),
          ),
        ]);

        expect(updated, isNull);
        expect(await _rawRows(database), before);
      });

      test('a created Card belongs to the signed-in Account', () async {
        await dataSource.createCard(
          const CardDto(id: 'card-11', title: 'New', description: 'New'),
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

        await expectLater(dataSource.getCards(), throwsStateError);
        await expectLater(dataSource.getCardById('card-1'), throwsStateError);
        await expectLater(
          dataSource.createCard(
            const CardDto(id: 'card-11', title: 'New', description: 'New'),
          ),
          throwsStateError,
        );
        await expectLater(
          dataSource.updateCard(
            const CardDto(id: 'card-1', title: 'Edit', description: 'Edit'),
          ),
          throwsStateError,
        );
        await expectLater(dataSource.deleteCard('card-1'), throwsStateError);
        await expectLater(dataSource.getUnsyncedCards(), throwsStateError);
        await expectLater(
          dataSource.markCardsSynced([CardDto.fromDatabaseRow(_row(1))]),
          throwsStateError,
        );
      });
    });

    group('adoption', () {
      setUp(() async {
        await _insertRows(database, [
          _row(6, userId: null),
          _row(7, userId: null, status: 'updated'),
          _row(8, userId: null, status: 'created', lastSyncedAt: null),
          _row(9, userId: null, status: 'deleted'),
        ]);
      });

      test('the first read adopts unowned Cards as never synced', () async {
        final cards = await dataSource.getCards();
        final rows = {
          for (final row in await _rawRows(database)) row['id']: row,
        };

        expect(
          cards.map((card) => card.id),
          containsAll(<String>['card-6', 'card-7', 'card-8']),
        );
        expect(rows['card-6'], {
          ..._row(6, userId: _accountA, status: 'created', lastSyncedAt: null),
        });
        expect(rows['card-7'], {
          ..._row(7, userId: _accountA, status: 'created', lastSyncedAt: null),
        });
        expect(rows['card-8'], {
          ..._row(8, userId: _accountA, status: 'created', lastSyncedAt: null),
        });
        expect(rows, isNot(contains('card-9')));
      });

      test('the first write adopts unowned Cards before it runs', () async {
        await dataSource.deleteCard('card-6');

        final rows = await _rawRows(database);

        expect(rows.map((row) => row['user_id']), everyElement(_accountA));
        expect(rows.map((row) => row['id']), isNot(contains('card-6')));
      });

      test('adopted Cards are pushed by the next sync', () async {
        expect(
          (await dataSource.getUnsyncedCards()).map((card) => card.id),
          <String>['card-6', 'card-7', 'card-8'],
        );
      });

      test('a later Account adopts nothing the first one took', () async {
        await dataSource.getCards();
        sessionHolder.signedInUid = _accountB;

        expect(await dataSource.getCards(), isEmpty);
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
