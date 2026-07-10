import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';

@LazySingleton(as: CardsDataSource)
class CardsLocalDataSource implements CardsDataSource {
  const CardsLocalDataSource(this._database);

  static const _tableName = 'cards';

  final AppDatabase _database;

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
  Future<void> createCard(CardDto card) {
    return _database.write((db) async {
      final now = DateTime.now().toUtc();
      await db.insert(
        _tableName,
        CardDto(
          id: card.id,
          title: card.title,
          description: card.description,
          syncStatus: CardSyncStatus.created,
          updatedAt: now,
        ).toDatabaseRow(),
      );
    });
  }

  @override
  Future<void> updateCard(CardDto card) {
    return _database.write((db) async {
      final existingCard = await _getCardByIdIncludingDeleted(db, card.id);
      if (existingCard == null) {
        return;
      }

      final now = DateTime.now().toUtc();
      final syncStatus = existingCard.syncStatus == CardSyncStatus.created
          ? CardSyncStatus.created
          : CardSyncStatus.updated;

      await db.update(
        _tableName,
        CardDto(
          id: card.id,
          title: card.title,
          description: card.description,
          syncStatus: syncStatus,
          updatedAt: now,
          lastSyncedAt: existingCard.lastSyncedAt,
          deletedAt: null,
        ).toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
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

  Future<List<CardDto>> getDirtyCards() {
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
