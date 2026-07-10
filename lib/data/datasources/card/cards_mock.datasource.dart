import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

class MockCardsDataSource implements CardsDataSource {
  @override
  Future<List<CardDto>> getCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<CardDto>.generate(
      10,
      (index) => CardDto(
        id: 'card-${index + 1}',
        title: 'Card Title ${index + 1}',
        description:
            'This is the body copy for card number ${index + 1}. '
            'You can replace this with whatever description you want.',
      ),
      growable: false,
    );
  }

  @override
  Future<CardDto?> getCardById(String cardId) async {
    final cards = await getCards();

    for (final card in cards) {
      if (card.id == cardId) {
        return card;
      }
    }

    return null;
  }
}
