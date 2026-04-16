import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/mock_cards_data_source.dart';
import 'package:project_tweety/domain/entities/card_item.dart';
import 'package:project_tweety/domain/repositories/cards_repository.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._mockCardsDataSource);

  final MockCardsDataSource _mockCardsDataSource;

  @override
  Future<List<CardItem>> getCards() async {
    final items = await _mockCardsDataSource.getCards();
    return items.map((item) => item.toEntity()).toList(growable: false);
  }
}
