import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

class MockCardsDataSource implements CardsDataSource {
  final List<CardDto> _cards = List<CardDto>.generate(
    10,
    (index) => CardDto(
      id: 'card-${index + 1}',
      title: 'Card Title ${index + 1}',
      description:
          'This is the body copy for card number ${index + 1}. '
          'You can replace this with whatever description you want.',
    ),
  );

  @override
  Future<List<CardDto>> getCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<CardDto>.unmodifiable(
      _cards.where((card) => card.syncStatus != CardSyncStatus.deleted),
    );
  }

  @override
  Future<CardDto?> getCardById(String cardId) async {
    final cards = await getCards();

    for (final card in cards) {
      if (card.id == cardId) {
        return card;
      }
    }

    return null;
  }

  @override
  Future<CardDto> createCard(CardDto card) async {
    final createdCard = CardDto(
      id: card.id,
      title: card.title,
      description: card.description,
      syncStatus: CardSyncStatus.created,
      updatedAt: DateTime.now().toUtc(),
    );
    _cards.add(createdCard);
    return createdCard;
  }

  @override
  Future<CardDto?> updateCard(CardDto card) async {
    final index = _cards.indexWhere((item) => item.id == card.id);
    if (index == -1 || _cards[index].syncStatus == CardSyncStatus.deleted) {
      return null;
    }

    final existingCard = _cards[index];
    final updatedCard = CardDto(
      id: card.id,
      title: card.title,
      description: card.description,
      syncStatus: existingCard.syncStatus == CardSyncStatus.created
          ? CardSyncStatus.created
          : CardSyncStatus.updated,
      updatedAt: DateTime.now().toUtc(),
      lastSyncedAt: existingCard.lastSyncedAt,
    );
    _cards[index] = updatedCard;
    return updatedCard;
  }

  @override
  Future<void> deleteCard(String cardId) async {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index == -1) {
      return;
    }

    final existingCard = _cards[index];
    if (existingCard.syncStatus == CardSyncStatus.created) {
      _cards.removeAt(index);
      return;
    }

    final now = DateTime.now().toUtc();
    _cards[index] = CardDto(
      id: existingCard.id,
      title: existingCard.title,
      description: existingCard.description,
      syncStatus: CardSyncStatus.deleted,
      updatedAt: now,
      lastSyncedAt: existingCard.lastSyncedAt,
      deletedAt: now,
    );
  }

  @override
  Future<List<CardDto>> getUnsyncedCards() async {
    return List<CardDto>.unmodifiable(
      _cards.where((card) => card.syncStatus != CardSyncStatus.synced),
    );
  }

  @override
  Future<void> markCardsSynced(List<String> cardIds) async {
    if (cardIds.isEmpty) {
      return;
    }

    final cardIdSet = cardIds.toSet();
    _cards.removeWhere(
      (card) =>
          cardIdSet.contains(card.id) &&
          card.syncStatus == CardSyncStatus.deleted,
    );

    final now = DateTime.now().toUtc();
    for (var index = 0; index < _cards.length; index++) {
      final card = _cards[index];
      if (!cardIdSet.contains(card.id)) {
        continue;
      }

      _cards[index] = CardDto(
        id: card.id,
        title: card.title,
        description: card.description,
        syncStatus: CardSyncStatus.synced,
        updatedAt: card.updatedAt,
        lastSyncedAt: now,
      );
    }
  }
}
