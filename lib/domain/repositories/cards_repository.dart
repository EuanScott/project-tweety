import 'package:project_tweety/domain/entities/card_item.dart';

abstract class CardsRepository {
  Future<List<CardItem>> getCards();
}
