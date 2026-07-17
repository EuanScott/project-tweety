import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('CardsLocalDataSource', () {
    late Directory temporaryDirectory;
    late AppDatabase database;
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
      dataSource = CardsLocalDataSource(database);
    });

    tearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test('returns stored cards in insertion order', () async {
      final cards = await dataSource.getCards();

      expect(cards.map((card) => card.id), <String>[
        'card-1',
        'card-2',
        'card-3',
        'card-4',
        'card-5',
        'card-6',
        'card-7',
        'card-8',
        'card-9',
        'card-10',
      ]);
      expect(cards.first.title, 'Card Title 1');
      expect(
        cards.first.description,
        'This is the body copy for card number 1. '
        'You can replace this with whatever description you want.',
      );
    });

    test('returns a stored card by id', () async {
      final card = await dataSource.getCardById('card-7');

      expect(card?.id, 'card-7');
      expect(card?.title, 'Card Title 7');
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

    test('creates a readable card in dirty created state', () async {
      await dataSource.createCard(
        const CardDto(
          id: 'card-11',
          title: 'New card',
          description: 'New card description',
        ),
      );

      final storedCard = await dataSource.getCardById('card-11');
      final dirtyCards = await dataSource.getDirtyCards();

      expect(storedCard?.title, 'New card');
      expect(dirtyCards.single.id, 'card-11');
      expect(dirtyCards.single.syncStatus, CardSyncStatus.created);
      expect(dirtyCards.single.updatedAt?.isUtc, isTrue);
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

    test('updates a synced card into dirty updated state', () async {
      await dataSource.updateCard(
        const CardDto(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        ),
      );

      final storedCard = await dataSource.getCardById('card-1');
      final dirtyCards = await dataSource.getDirtyCards();

      expect(storedCard?.title, 'Updated card');
      expect(dirtyCards.single.id, 'card-1');
      expect(dirtyCards.single.syncStatus, CardSyncStatus.updated);
      expect(dirtyCards.single.updatedAt?.isUtc, isTrue);
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

      final dirtyCards = await dataSource.getDirtyCards();

      expect(dirtyCards.single.id, 'card-11');
      expect(dirtyCards.single.title, 'Updated new card');
      expect(dirtyCards.single.syncStatus, CardSyncStatus.created);
    });

    test('tombstones a synced card and hides it from reads', () async {
      await dataSource.deleteCard('card-1');

      final storedCard = await dataSource.getCardById('card-1');
      final cards = await dataSource.getCards();
      final dirtyCards = await dataSource.getDirtyCards();

      expect(storedCard, isNull);
      expect(cards.map((item) => item.id), isNot(contains('card-1')));
      expect(dirtyCards.single.id, 'card-1');
      expect(dirtyCards.single.syncStatus, CardSyncStatus.deleted);
      expect(dirtyCards.single.deletedAt?.isUtc, isTrue);
    });

    test(
      'does not resurrect a tombstone when a stale update arrives',
      () async {
        await dataSource.deleteCard('card-1');

        await dataSource.updateCard(
          const CardDto(
            id: 'card-1',
            title: 'Stale update',
            description: 'Must not cancel the pending delete',
          ),
        );

        final dirtyCards = await dataSource.getDirtyCards();

        expect(await dataSource.getCardById('card-1'), isNull);
        expect(dirtyCards.single.id, 'card-1');
        expect(dirtyCards.single.syncStatus, CardSyncStatus.deleted);
        expect(dirtyCards.single.title, 'Card Title 1');
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
      expect(await dataSource.getDirtyCards(), isEmpty);
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

      await dataSource.markCardsSynced(['card-11', 'card-1', 'card-2']);

      final createdCard = await dataSource.getCardById('card-11');
      final updatedCard = await dataSource.getCardById('card-1');

      expect(await dataSource.getDirtyCards(), isEmpty);
      expect(createdCard?.syncStatus, CardSyncStatus.synced);
      expect(createdCard?.lastSyncedAt?.isUtc, isTrue);
      expect(updatedCard?.syncStatus, CardSyncStatus.synced);
      expect(updatedCard?.lastSyncedAt?.isUtc, isTrue);
      expect(await dataSource.getCardById('card-2'), isNull);
    });

    test('accepts an empty uploaded card batch', () async {
      await dataSource.markCardsSynced(const []);

      expect(await dataSource.getDirtyCards(), isEmpty);
    });
  });
}
