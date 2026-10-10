import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_remote.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/fake_session_holder.dart';

void main() {
  group('CardsRepository', () {
    setUpAll(sqfliteFfiInit);

    group('CardsRepositoryImpl', () {
      test('maps datasource cards to repository values', () async {
        const repository = CardsRepositoryImpl(
          _FakeCardsDataSource(
            cards: [
              CardDto(
                id: 'card-42',
                title: 'Known card',
                description: 'Known description',
              ),
            ],
          ),
          _FixedCardIdGenerator('unused'),
          _UnusedCardsRemoteDataSource(),
        );

        final cards = await repository.getCards();

        expect(cards, const [
          Card(
            id: 'card-42',
            title: 'Known card',
            description: 'Known description',
          ),
        ]);
      });

      test('maps a datasource card lookup to a repository value', () async {
        const repository = CardsRepositoryImpl(
          _FakeCardsDataSource(
            cardsById: {
              'card-42': CardDto(
                id: 'card-42',
                title: 'Known card',
                description: 'Known description',
              ),
            },
          ),
          _FixedCardIdGenerator('unused'),
          _UnusedCardsRemoteDataSource(),
        );

        final card = await repository.getCardById('card-42');

        expect(
          card,
          const Card(
            id: 'card-42',
            title: 'Known card',
            description: 'Known description',
          ),
        );
      });

      test('preserves a missing datasource card lookup', () async {
        const repository = CardsRepositoryImpl(
          _FakeCardsDataSource(),
          _FixedCardIdGenerator('unused'),
          _UnusedCardsRemoteDataSource(),
        );

        final card = await repository.getCardById('missing-card');

        expect(card, isNull);
      });

      test(
        'creates a trimmed card with an injected id and returned DTO',
        () async {
          final dataSource = _RecordingCardsDataSource(
            createdCard: const CardDto(
              id: 'generated-id',
              title: 'Trimmed title',
              description: 'Trimmed description',
            ),
          );
          final repository = CardsRepositoryImpl(
            dataSource,
            const _FixedCardIdGenerator('generated-id'),
            const _UnusedCardsRemoteDataSource(),
          );

          final card = await repository.createCard(
            const CardDraft(
              title: '  Trimmed title  ',
              description: '  Trimmed description  ',
            ),
          );

          expect(dataSource.createdDraft?.id, 'generated-id');
          expect(dataSource.createdDraft?.title, 'Trimmed title');
          expect(dataSource.createdDraft?.description, 'Trimmed description');
          expect(
            card,
            const Card(
              id: 'generated-id',
              title: 'Trimmed title',
              description: 'Trimmed description',
            ),
          );
        },
      );

      test('rejects blank trimmed fields without generating an id', () async {
        final idGenerator = _CountingCardIdGenerator();
        final repository = CardsRepositoryImpl(
          const _FakeCardsDataSource(),
          idGenerator,
          const _UnusedCardsRemoteDataSource(),
        );

        await expectLater(
          repository.createCard(
            const CardDraft(title: ' ', description: '\n\t'),
          ),
          throwsA(
            isA<InvalidCardDraftException>().having(
              (exception) => exception.invalidFields,
              'invalid fields',
              {CardDraftField.title, CardDraftField.description},
            ),
          ),
        );
        expect(idGenerator.callCount, 0);
      });

      test('reports a missing update target with its card id', () async {
        const repository = CardsRepositoryImpl(
          _MissingUpdateCardsDataSource(),
          _FixedCardIdGenerator('unused'),
          _UnusedCardsRemoteDataSource(),
        );

        await expectLater(
          repository.updateCard(
            cardId: 'missing-card',
            draft: const CardDraft(
              title: 'Updated title',
              description: 'Updated description',
            ),
          ),
          throwsA(
            isA<CardNotFoundException>().having(
              (exception) => exception.cardId,
              'card id',
              'missing-card',
            ),
          ),
        );
      });
    });

    group('CardsRepositoryImpl with SQLite', () {
      late Directory temporaryDirectory;
      late AppDatabase database;
      late CardsRepository repository;
      late _FakeCardsRemoteDataSource remote;

      setUp(() async {
        temporaryDirectory = await Directory.systemTemp.createTemp(
          'project_tweety_cards_repository_',
        );
        database = SqfliteAppDatabase.test(
          databaseFactory: databaseFactoryFfi,
          databasePath: '${temporaryDirectory.path}/project_tweety.db',
        );
        remote = _FakeCardsRemoteDataSource();
        repository = CardsRepositoryImpl(
          CardsLocalDataSource(database, FakeSessionHolder()),
          const _FixedCardIdGenerator('card-11'),
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
        'creates a card that is retrievable through the repository',
        () async {
          const draft = CardDraft(
            title: 'New card',
            description: 'New card description',
          );

          final card = await repository.createCard(draft);

          expect(await repository.getCardById('card-11'), card);
        },
      );

      test('updates a card through the repository', () async {
        const draft = CardDraft(
          title: 'Updated card',
          description: 'Updated card description',
        );

        final card = await repository.updateCard(
          cardId: 'card-1',
          draft: draft,
        );

        expect(await repository.getCardById('card-1'), card);
      });

      test('propagates a duplicate generated id from SQLite', () async {
        final duplicateIdRepository = CardsRepositoryImpl(
          CardsLocalDataSource(database, FakeSessionHolder()),
          const _FixedCardIdGenerator('card-1'),
          remote,
        );

        await expectLater(
          duplicateIdRepository.createCard(
            const CardDraft(
              title: 'Duplicate card',
              description: 'Duplicate description',
            ),
          ),
          throwsA(isA<DatabaseException>()),
        );
      });

      test('deletes a card through the repository', () async {
        await repository.deleteCard('card-1');

        expect(await repository.getCardById('card-1'), isNull);
      });

      test('deleting a missing card succeeds idempotently', () async {
        await repository.deleteCard('missing-card');

        expect(await repository.getCards(), hasLength(1));
      });

      group('sync', () {
        Future<void> makeThreeChanges() async {
          await repository.createCard(
            const CardDraft(title: 'New', description: 'New'),
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
          await repository.updateCard(
            cardId: 'card-1',
            draft: const CardDraft(title: 'Edited', description: 'Edited'),
          );
          await repository.deleteCard('card-2');
        }

        test('the summary names each pending change', () async {
          await makeThreeChanges();

          final summary = await repository.getSyncSummary();

          expect(summary.pendingChanges, {
            'card-11': PendingCardChange.created,
            'card-1': PendingCardChange.updated,
            'card-2': PendingCardChange.deleted,
          });
        });

        test('with nothing pending, a sync pushes nothing', () async {
          final result = await repository.syncCards();

          expect(result, const CardsSyncResult(changeCount: 0, savedCount: 0));
          expect(remote.pushed, isEmpty);
        });

        test('pushes every pending change, reports progress, and leaves '
            'nothing pending', () async {
          await makeThreeChanges();
          final progress = <(int, int)>[];

          final result = await repository.syncCards(
            onProgress: (saved, total) => progress.add((saved, total)),
          );
          final summary = await repository.getSyncSummary();

          expect(
            remote.pushed.map((card) => card.id),
            unorderedEquals(['card-11', 'card-1', 'card-2']),
          );
          expect(progress, [(0, 3), (1, 3), (2, 3), (3, 3)]);
          expect(result, const CardsSyncResult(changeCount: 3, savedCount: 3));
          expect(summary.pendingChanges, isEmpty);
          expect(summary.lastSyncedAt, isNotNull);
        });

        test('a partial push keeps what failed pending', () async {
          await makeThreeChanges();
          remote.outcomes['card-1'] = CardPushOutcome.failure;

          final result = await repository.syncCards();
          final summary = await repository.getSyncSummary();

          expect(result, const CardsSyncResult(changeCount: 3, savedCount: 2));
          expect(summary.pendingChanges, {'card-1': PendingCardChange.updated});
        });

        test('says when every failure was a network failure', () async {
          await makeThreeChanges();
          for (final id in ['card-11', 'card-1', 'card-2']) {
            remote.outcomes[id] = CardPushOutcome.networkFailure;
          }

          final result = await repository.syncCards();

          expect(
            result,
            const CardsSyncResult(
              changeCount: 3,
              savedCount: 0,
              onlyNetworkFailures: true,
            ),
          );
          expect((await repository.getSyncSummary()).pendingChanges.length, 3);
        });

        test('a Card edited while its push is in flight stays '
            'pending', () async {
          await makeThreeChanges();
          remote.whilePushing = () => repository.updateCard(
            cardId: 'card-11',
            draft: const CardDraft(title: 'Edited again', description: 'New'),
          );

          await repository.syncCards();

          expect((await repository.getSyncSummary()).pendingChanges, {
            'card-11': PendingCardChange.created,
          });
        });
      });
    });
  });
}

class _FakeCardsDataSource implements CardsDataSource {
  const new({this.cards = const [], this.cardsById = const {}});

  final List<CardDto> cards;
  final Map<String, CardDto> cardsById;

  @override
  Future<CardDto> createCard(CardDto card) async => card;

  @override
  Future<CardDto?> updateCard(CardDto card) async => card;

  @override
  Future<void> deleteCard(String cardId) async {}

  @override
  Future<List<CardDto>> getUnsyncedCards() async => const [];

  @override
  Future<void> markCardsSynced(List<CardDto> pushedCards) async {}

  @override
  Future<List<CardDto>> getCards() async => cards;

  @override
  Future<CardDto?> getCardById(String cardId) async => cardsById[cardId];
}

class _RecordingCardsDataSource extends _FakeCardsDataSource {
  new({required this.createdCard});

  final CardDto createdCard;
  CardDto? createdDraft;

  @override
  Future<CardDto> createCard(CardDto card) async {
    createdDraft = card;
    return createdCard;
  }
}

class _MissingUpdateCardsDataSource extends _FakeCardsDataSource {
  const new();

  @override
  Future<CardDto?> updateCard(CardDto card) async => null;
}

class _FixedCardIdGenerator implements CardIdGenerator {
  const new(this.value);

  final String value;

  @override
  String generate() => value;
}

class _CountingCardIdGenerator implements CardIdGenerator {
  int callCount = 0;

  @override
  String generate() {
    callCount++;
    return 'generated-$callCount';
  }
}

class const _UnusedCardsRemoteDataSource() implements CardsRemoteDataSource {
  @override
  Future<Map<String, CardPushOutcome>> pushCards(
    List<CardDto> cards, {
    void Function(String cardId, CardPushOutcome outcome)? onPushed,
  }) => throw UnimplementedError();
}

/// Confirms every Card unless [outcomes] says otherwise. [whilePushing] runs
/// after the snapshot is taken and before any write settles.
class _FakeCardsRemoteDataSource implements CardsRemoteDataSource {
  final outcomes = <String, CardPushOutcome>{};
  final pushed = <CardDto>[];
  Future<void> Function()? whilePushing;

  @override
  Future<Map<String, CardPushOutcome>> pushCards(
    List<CardDto> cards, {
    void Function(String cardId, CardPushOutcome outcome)? onPushed,
  }) async {
    await whilePushing?.call();
    pushed.addAll(cards);
    final result = {
      for (final card in cards)
        card.id: outcomes[card.id] ?? CardPushOutcome.confirmed,
    };
    result.forEach((cardId, outcome) => onPushed?.call(cardId, outcome));

    return result;
  }
}
