import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';

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
}
