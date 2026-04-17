import 'package:project_tweety/domain/entities/card.entity.dart';

abstract class CardsRepository {
  Future<List<Card>> getCards();
  Future<Card?> getCardById(String cardId);
  Future<Card> createCard(Card card);
  Future<Card> updateCard(Card card);
  Future<void> deleteCard(String cardId);
}
