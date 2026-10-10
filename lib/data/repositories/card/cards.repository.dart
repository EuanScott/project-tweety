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
  const factory({required String title, required String description}) =
      _CardDraft;

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

/// A change on this device that the Account's copy does not have yet.
enum PendingCardChange { created, updated, deleted }

/// Where sync stands while no sync is running.
@freezed
abstract class CardsSyncSummary with _$CardsSyncSummary {
  const factory({
    @Default(<String, PendingCardChange>{})
    Map<String, PendingCardChange> pendingChanges,

    /// The latest time any Card still on this device was synced.
    DateTime? lastSyncedAt,
  }) = _CardsSyncSummary;
}

/// How one sync ended. [changeCount] is what it tried to push, and
/// [savedCount] is what the server confirmed.
@freezed
abstract class CardsSyncResult with _$CardsSyncResult {
  const factory({
    required int changeCount,
    required int savedCount,

    /// Whether every change that was not saved failed because the server
    /// could not be reached, rather than because it refused the change.
    @Default(false) bool onlyNetworkFailures,
  }) = _CardsSyncResult;
}

abstract class CardsRepository {
  Future<List<Card>> getCards();

  Future<Card?> getCardById(String cardId);

  Future<Card> createCard(CardDraft draft);

  Future<Card> updateCard({required String cardId, required CardDraft draft});

  Future<void> deleteCard(String cardId);

  Future<CardsSyncSummary> getSyncSummary();

  /// Pushes every pending change. Calls [onProgress] once before the push
  /// with no changes saved, then again as the server confirms each one.
  Future<CardsSyncResult> syncCards({
    void Function(int savedCount, int changeCount)? onProgress,
  });
}
