import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_mock.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

void main() {
  test('follows the datasource dirty-sync contract', () async {
    final CardsDataSource dataSource = MockCardsDataSource();
    final createdCard = await dataSource.createCard(
      const CardDto(
        id: 'card-11',
        title: 'New card',
        description: 'New card description',
      ),
    );

    expect(createdCard.syncStatus, CardSyncStatus.created);
    expect(createdCard.updatedAt?.isUtc, isTrue);

    final dirtyCards = await dataSource.getDirtyCards();
    expect(dirtyCards.single.id, 'card-11');
    expect(dirtyCards.single.syncStatus, CardSyncStatus.created);

    await dataSource.markCardsSynced(['card-11']);

    expect(await dataSource.getDirtyCards(), isEmpty);
    final syncedCard = await dataSource.getCardById('card-11');
    expect(syncedCard?.syncStatus, CardSyncStatus.synced);
    expect(syncedCard?.lastSyncedAt?.isUtc, isTrue);
  });

  test('hides deleted tombstones from normal reads', () async {
    final CardsDataSource dataSource = MockCardsDataSource();

    await dataSource.deleteCard('card-1');

    expect(
      (await dataSource.getCards()).map((card) => card.id),
      isNot(contains('card-1')),
    );
    expect(await dataSource.getCardById('card-1'), isNull);
    final dirtyCards = await dataSource.getDirtyCards();
    expect(dirtyCards.single.id, 'card-1');
    expect(dirtyCards.single.syncStatus, CardSyncStatus.deleted);
  });
}
