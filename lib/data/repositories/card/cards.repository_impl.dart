import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_remote.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';

import 'cards.repository.dart';

@LazySingleton(as: CardsRepository)
class const CardsRepositoryImpl(
  final CardsDataSource _dataSource,
  final CardIdGenerator _cardIdGenerator,
  final CardsRemoteDataSource _remoteDataSource,
) implements CardsRepository {
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

  @override
  Future<Card> createCard(CardDraft draft) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.createCard(
      CardDto(
        id: _cardIdGenerator.generate(),
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    return item.toValue();
  }

  @override
  Future<Card> updateCard({
    required String cardId,
    required CardDraft draft,
  }) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.updateCard(
      CardDto(
        id: cardId,
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    if (item == null) {
      throw CardNotFoundException(cardId);
    }
    return item.toValue();
  }

  @override
  Future<void> deleteCard(String cardId) {
    return _dataSource.deleteCard(cardId);
  }

  @override
  Future<CardsSyncSummary> getSyncSummary() async {
    final unsyncedCards = await _dataSource.getUnsyncedCards();
    final cards = await _dataSource.getCards();
    DateTime? lastSyncedAt;
    for (final card in cards) {
      final cardSyncedAt = card.lastSyncedAt;
      if (cardSyncedAt != null &&
          (lastSyncedAt == null || cardSyncedAt.isAfter(lastSyncedAt))) {
        lastSyncedAt = cardSyncedAt;
      }
    }

    return CardsSyncSummary(
      pendingChanges: {
        for (final card in unsyncedCards)
          card.id: switch (card.syncStatus) {
            CardSyncStatus.created => PendingCardChange.created,
            CardSyncStatus.deleted => PendingCardChange.deleted,
            CardSyncStatus.updated ||
            CardSyncStatus.synced => PendingCardChange.updated,
          },
      },
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  Future<CardsSyncResult> syncCards({
    void Function(int savedCount, int changeCount)? onProgress,
  }) async {
    final pendingCards = await _dataSource.getUnsyncedCards();
    final changeCount = pendingCards.length;
    if (changeCount == 0) {
      return const CardsSyncResult(changeCount: 0, savedCount: 0);
    }

    onProgress?.call(0, changeCount);
    var savedCount = 0;
    final outcomes = await _remoteDataSource.pushCards(
      pendingCards,
      onPushed: (_, outcome) {
        if (outcome == CardPushOutcome.confirmed) {
          onProgress?.call(++savedCount, changeCount);
        }
      },
    );
    final confirmedCards = [
      for (final card in pendingCards)
        if (outcomes[card.id] == CardPushOutcome.confirmed) card,
    ];
    await _dataSource.markCardsSynced(confirmedCards);

    final failures = outcomes.values.where(
      (outcome) => outcome != CardPushOutcome.confirmed,
    );

    return CardsSyncResult(
      changeCount: changeCount,
      savedCount: confirmedCards.length,
      onlyNetworkFailures:
          failures.isNotEmpty &&
          failures.every(
            (outcome) => outcome == CardPushOutcome.networkFailure,
          ),
    );
  }

  CardDraft _validatedTrimmedDraft(CardDraft draft) {
    final invalidFields = draft.invalidFields;
    if (invalidFields.isNotEmpty) {
      throw InvalidCardDraftException(invalidFields);
    }
    return draft.trimmed();
  }
}
