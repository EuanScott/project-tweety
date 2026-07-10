import 'package:equatable/equatable.dart';

class Card extends Equatable {
  const Card({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  @override
  List<Object> get props => [id, title, description];
}

abstract class CardsRepository {
  Future<List<Card>> getCards();

  Future<Card?> getCardById(String cardId);

  Future<void> createCard(Card card);

  Future<void> updateCard(Card card);

  Future<void> deleteCard(String cardId);
}
