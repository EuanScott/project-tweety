import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/card.mock.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart';
import 'package:project_tweety/domain/repositories/card/card.repository.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._mockCardsDataSource);

  final MockCardsDataSource _mockCardsDataSource;

  @override
  Future<List<Card>> getCards() async {
    final items = await _mockCardsDataSource.getCards();
    return items.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<Card> createCard(Card card) {
    // TODO: implement createCard
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String cardId) {
    // TODO: implement deleteCard
    throw UnimplementedError();
  }

  @override
  Future<Card?> getCardById(String cardId) {
    // TODO: implement getCardById
    throw UnimplementedError();
  }

  @override
  Future<Card> updateCard(Card card) {
    // TODO: implement updateCard
    throw UnimplementedError();
  }
}
