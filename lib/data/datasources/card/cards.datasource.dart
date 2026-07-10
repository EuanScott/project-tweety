import 'package:project_tweety/data/dtos/card/card.dto.dart';

abstract class CardsDataSource {
  Future<List<CardDto>> getCards();

  Future<CardDto?> getCardById(String cardId);

  Future<void> createCard(CardDto card);

  Future<void> updateCard(CardDto card);

  Future<void> deleteCard(String cardId);

  Future<List<CardDto>> getDirtyCards();

  Future<void> markCardsSynced(List<String> cardIds);
}
