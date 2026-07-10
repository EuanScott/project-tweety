import 'package:project_tweety/data/dtos/card/card.dto.dart';

abstract class CardsDataSource {
  Future<List<CardDto>> getCards();

  Future<CardDto?> getCardById(String cardId);
}
