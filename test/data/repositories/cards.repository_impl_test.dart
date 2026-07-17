import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        const repository = CardsRepositoryImpl(_FakeCardsDataSource());

        final card = await repository.getCardById('missing-card');

        expect(card, isNull);
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
        repository = CardsRepositoryImpl(CardsLocalDataSource(database));
      });

      tearDown(() async {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      });

      test(
        'creates a card that is retrievable through the repository',
        () async {
          const card = Card(
            id: 'card-11',
            title: 'New card',
            description: 'New card description',
          );

          await repository.createCard(card);

          expect(await repository.getCardById('card-11'), card);
        },
      );

      test('updates a card through the repository', () async {
        const card = Card(
          id: 'card-1',
          title: 'Updated card',
          description: 'Updated card description',
        );

        await repository.updateCard(card);

        expect(await repository.getCardById('card-1'), card);
      });

      test('deletes a card through the repository', () async {
        await repository.deleteCard('card-1');

        expect(await repository.getCardById('card-1'), isNull);
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
  Future<void> createCard(CardDto card) async {}

  @override
  Future<void> updateCard(CardDto card) async {}

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
