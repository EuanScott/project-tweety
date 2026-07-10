import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';

void main() {
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
}

class _FakeCardsDataSource implements CardsDataSource {
  const _FakeCardsDataSource({
    this.cards = const [],
    this.cardsById = const {},
  });

  final List<CardDto> cards;
  final Map<String, CardDto> cardsById;

  @override
  Future<List<CardDto>> getCards() async => cards;

  @override
  Future<CardDto?> getCardById(String cardId) async => cardsById[cardId];
}
