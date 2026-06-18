import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/card.mock.dart';

import 'cards.repository.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._mockCardsDataSource);

  final MockCardsDataSource _mockCardsDataSource;

  @override
  Future<List<Card>> getCards() async {
    final items = await _mockCardsDataSource.getCards();
    return items.map((item) => item.toValue()).toList(growable: false);
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    final items = await getCards();

    for (final item in items) {
      if (item.id == cardId) {
        return item;
      }
    }

    return null;
  }
}
