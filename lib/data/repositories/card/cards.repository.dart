import 'package:freezed_annotation/freezed_annotation.dart';

part 'cards.repository.freezed.dart';

@freezed
abstract class Card with _$Card {
  const factory({
    required String id,
    required String title,
    required String description,
  }) = _Card;
}

@freezed
abstract class CardDraft with _$CardDraft {
  const factory({
    required String title,
    required String description,
  }) = _CardDraft;

  const new _();

  Set<CardDraftField> get invalidFields {
    return {
      if (title.trim().isEmpty) CardDraftField.title,
      if (description.trim().isEmpty) CardDraftField.description,
    };
  }

  CardDraft trimmed() {
    return CardDraft(title: title.trim(), description: description.trim());
  }
}

enum CardDraftField { title, description }

class InvalidCardDraftException implements Exception {
  new(Iterable<CardDraftField> invalidFields)
    : invalidFields = Set<CardDraftField>.unmodifiable(invalidFields);

  final Set<CardDraftField> invalidFields;
}

class const CardNotFoundException(final String cardId) implements Exception;

abstract class CardsRepository {
  Future<List<Card>> getCards();

  Future<Card?> getCardById(String cardId);

  Future<Card> createCard(CardDraft draft);

  Future<Card> updateCard({required String cardId, required CardDraft draft});

  Future<void> deleteCard(String cardId);
}
