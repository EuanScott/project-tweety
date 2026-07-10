import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

import 'cards.repository.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._dataSource);

  final CardsDataSource _dataSource;

  @override
  Future<List<Card>> getCards() async {
    final items = await _dataSource.getCards();
    return items.map((item) => item.toValue()).toList(growable: false);
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    final item = await _dataSource.getCardById(cardId);
    return item?.toValue();
  }

  @override
  Future<void> createCard(Card card) {
    return _dataSource.createCard(_toDto(card));
  }

  @override
  Future<void> updateCard(Card card) {
    return _dataSource.updateCard(_toDto(card));
  }

  @override
  Future<void> deleteCard(String cardId) {
    return _dataSource.deleteCard(cardId);
  }

  CardDto _toDto(Card card) {
    return CardDto(
      id: card.id,
      title: card.title,
      description: card.description,
    );
  }
}
