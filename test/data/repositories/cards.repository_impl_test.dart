import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('CardsRepository', () {
    setUpAll(sqfliteFfiInit);

    group('CardsRepositoryImpl', () {
      test('generates UUID v4 card ids', () {
        final cardId = UuidCardIdGenerator().generate();

        expect(
          cardId,
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
      });

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

      setUp(() async {
        temporaryDirectory = await Directory.systemTemp.createTemp(
          'project_tweety_cards_repository_',
        );
        database = SqfliteAppDatabase.test(
          databaseFactory: databaseFactoryFfi,
          databasePath: '${temporaryDirectory.path}/project_tweety.db',
        );
        repository = CardsRepositoryImpl(
          CardsLocalDataSource(database),
          const _FixedCardIdGenerator('card-11'),
        );
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
          CardsLocalDataSource(database),
          const _FixedCardIdGenerator('card-1'),
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

        expect(await repository.getCards(), hasLength(10));
      });
    });
  });
}

class _FakeCardsDataSource implements CardsDataSource {
  const _FakeCardsDataSource({
    this.cards = const [],
    this.cardsById = const {},
  });

  final List<CardDto> cards;
  final Map<String, CardDto> cardsById;

  @override
  Future<CardDto> createCard(CardDto card) async => card;

  @override
  Future<CardDto?> updateCard(CardDto card) async => card;

  @override
  Future<void> deleteCard(String cardId) async {}

  @override
  Future<List<CardDto>> getDirtyCards() async => const [];

  @override
  Future<void> markCardsSynced(List<String> cardIds) async {}

  @override
  Future<List<CardDto>> getCards() async => cards;

  @override
  Future<CardDto?> getCardById(String cardId) async => cardsById[cardId];
}

class _RecordingCardsDataSource extends _FakeCardsDataSource {
  _RecordingCardsDataSource({required this.createdCard});

  final CardDto createdCard;
  CardDto? createdDraft;

  @override
  Future<CardDto> createCard(CardDto card) async {
    createdDraft = card;
    return createdCard;
  }
}

class _MissingUpdateCardsDataSource extends _FakeCardsDataSource {
  const _MissingUpdateCardsDataSource();

  @override
  Future<CardDto?> updateCard(CardDto card) async => null;
}

class _FixedCardIdGenerator implements CardIdGenerator {
  const _FixedCardIdGenerator(this.value);

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
