import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/card/card.mock.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';

void main() {
  group('CardsRepositoryImpl', () {
    test('returns a card by id', () async {
      final repository = CardsRepositoryImpl(MockCardsDataSource());

      final card = await repository.getCardById('card-1');

      expect(card?.id, 'card-1');
      expect(card?.title, 'Card Title 1');
    });

    test('returns null for an unknown card id', () async {
      final repository = CardsRepositoryImpl(MockCardsDataSource());

      final card = await repository.getCardById('missing-card');

      expect(card, isNull);
    });
  });
}
