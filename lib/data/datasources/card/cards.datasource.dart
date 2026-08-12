import 'package:project_tweety/data/dtos/card/card.dto.dart';

abstract class CardsDataSource {
  Future<List<CardDto>> getCards();

  Future<CardDto?> getCardById(String cardId);

  Future<CardDto> createCard(CardDto card);

  Future<CardDto?> updateCard(CardDto card);

  Future<void> deleteCard(String cardId);

  Future<List<CardDto>> getUnsyncedCards();

  Future<void> markCardsSynced(List<String> cardIds);
}
