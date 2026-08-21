import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

@LazySingleton(as: CardsDataSource)
class const CardsLocalDataSource(final AppDatabase _database)
    implements CardsDataSource {
  static const _tableName = 'cards';

  @override
  Future<List<CardDto>> getCards() {
    return _database.read((db) async {
      final rows = await db.query(
        _tableName,
        where: 'sync_status != ?',
        whereArgs: [CardSyncStatus.deleted.storageValue],
        orderBy: 'rowid ASC',
      );
      return rows.map(CardDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<CardDto?> getCardById(String cardId) {
    return _database.read((db) async {
      final rows = await db.query(
        _tableName,
        where: 'id = ? AND sync_status != ?',
        whereArgs: [cardId, CardSyncStatus.deleted.storageValue],
        limit: 1,
      );

      if (rows.isEmpty) {
        return null;
      }

      return CardDto.fromDatabaseRow(rows.single);
    });
  }

  @override
  Future<CardDto> createCard(CardDto card) {
    return _database.write((db) async {
      final now = DateTime.now().toUtc();
      final createdCard = CardDto(
        id: card.id,
        title: card.title,
        description: card.description,
        syncStatus: CardSyncStatus.created,
        updatedAt: now,
      );
      await db.insert(_tableName, createdCard.toDatabaseRow());
      return createdCard;
    });
  }

  @override
  Future<CardDto?> updateCard(CardDto card) {
    return _database.write((db) async {
      final existingCard = await _getCardByIdIncludingDeleted(db, card.id);
      if (existingCard == null ||
          existingCard.syncStatus == CardSyncStatus.deleted) {
        return null;
      }

      final now = DateTime.now().toUtc();
      final syncStatus = existingCard.syncStatus == CardSyncStatus.created
          ? CardSyncStatus.created
          : CardSyncStatus.updated;

      final updatedCard = CardDto(
        id: card.id,
        title: card.title,
        description: card.description,
        syncStatus: syncStatus,
        updatedAt: now,
        lastSyncedAt: existingCard.lastSyncedAt,
        deletedAt: null,
      );
      await db.update(
        _tableName,
        updatedCard.toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
      return updatedCard;
    });
  }

  @override
  Future<void> deleteCard(String cardId) {
    return _database.write((db) async {
      final existingCard = await _getCardByIdIncludingDeleted(db, cardId);
      if (existingCard == null) {
        return;
      }

      if (existingCard.syncStatus == CardSyncStatus.created) {
        await db.delete(_tableName, where: 'id = ?', whereArgs: [cardId]);
        return;
      }

      final now = DateTime.now().toUtc();
      await db.update(
        _tableName,
        <String, Object?>{
          'sync_status': CardSyncStatus.deleted.storageValue,
          'updated_at': now.toIso8601String(),
          'deleted_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [cardId],
      );
    });
  }

  @override
  Future<List<CardDto>> getUnsyncedCards() {
    return _database.read((db) async {
      final rows = await db.query(
        _tableName,
        where: 'sync_status != ?',
        whereArgs: [CardSyncStatus.synced.storageValue],
        orderBy: 'rowid ASC',
      );

      return rows.map(CardDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<void> markCardsSynced(List<String> cardIds) {
    if (cardIds.isEmpty) {
      return Future<void>.value();
    }

    return _database.write((db) async {
      final now = DateTime.now().toUtc().toIso8601String();
      final placeholders = _placeholders(cardIds);

      await db.delete(
        _tableName,
        where: 'id IN ($placeholders) AND sync_status = ?',
        whereArgs: [...cardIds, CardSyncStatus.deleted.storageValue],
      );

      await db.update(
        _tableName,
        <String, Object?>{
          'sync_status': CardSyncStatus.synced.storageValue,
          'last_synced_at': now,
          'deleted_at': null,
        },
        where: 'id IN ($placeholders)',
        whereArgs: cardIds,
      );
    });
  }

  Future<CardDto?> _getCardByIdIncludingDeleted(
    AppDatabaseReadExecutor db,
    String cardId,
  ) async {
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [cardId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CardDto.fromDatabaseRow(rows.single);
  }

  String _placeholders(List<Object?> values) {
    return List<String>.filled(values.length, '?').join(', ');
  }
}
