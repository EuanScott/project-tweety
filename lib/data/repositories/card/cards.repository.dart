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

class CardDraft extends Equatable {
  const CardDraft({required this.title, required this.description});

  final String title;
  final String description;

  Set<CardDraftField> get invalidFields {
    return {
      if (title.trim().isEmpty) CardDraftField.title,
      if (description.trim().isEmpty) CardDraftField.description,
    };
  }

  CardDraft trimmed() {
    return CardDraft(title: title.trim(), description: description.trim());
  }

  @override
  List<Object> get props => [title, description];
}

enum CardDraftField { title, description }

class InvalidCardDraftException implements Exception {
  InvalidCardDraftException(Iterable<CardDraftField> invalidFields)
    : invalidFields = Set<CardDraftField>.unmodifiable(invalidFields);

  final Set<CardDraftField> invalidFields;
}

class CardNotFoundException implements Exception {
  const CardNotFoundException(this.cardId);

  final String cardId;
}

abstract class CardsRepository {
  Future<List<Card>> getCards();

  Future<Card?> getCardById(String cardId);

  Future<Card> createCard(CardDraft draft);

  Future<Card> updateCard({required String cardId, required CardDraft draft});

  Future<void> deleteCard(String cardId);
}
