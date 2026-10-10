import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

/// Cards stored on this device, scoped to the signed-in Account.
///
/// Before its first operation for an Account, it adopts every unowned Card
/// in the same transaction as that operation, so nothing reads the table
/// before Adoption finishes.
@LazySingleton(as: CardsDataSource)
class CardsLocalDataSource(
  final AppDatabase _database,
  final SessionHolder _sessionHolder,
) implements CardsDataSource {
  static const _tableName = 'cards';

  String? _adoptedUid;

  @override
  Future<List<CardDto>> getCards() {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND sync_status != ?',
        whereArgs: [uid, CardSyncStatus.deleted.storageValue],
        orderBy: 'rowid ASC',
      );
      return rows.map(CardDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<CardDto?> getCardById(String cardId) {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'id = ? AND user_id = ? AND sync_status != ?',
        whereArgs: [cardId, uid, CardSyncStatus.deleted.storageValue],
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
    return _write((db, uid) async {
      final now = DateTime.now().toUtc();
      final createdCard = CardDto(
        id: card.id,
        title: card.title,
        description: card.description,
        syncStatus: CardSyncStatus.created,
        updatedAt: now,
        userId: uid,
      );
      await db.insert(_tableName, createdCard.toDatabaseRow());
      return createdCard;
    });
  }

  @override
  Future<CardDto?> updateCard(CardDto card) {
    return _write((db, uid) async {
      final existingCard = await _getCardByIdIncludingDeleted(db, uid, card.id);
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
        userId: uid,
      );
      await db.update(
        _tableName,
        updatedCard.toDatabaseRow(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [card.id, uid],
      );
      return updatedCard;
    });
  }

  @override
  Future<void> deleteCard(String cardId) {
    return _write((db, uid) async {
      final existingCard = await _getCardByIdIncludingDeleted(db, uid, cardId);
      if (existingCard == null) {
        return;
      }

      if (existingCard.syncStatus == CardSyncStatus.created) {
        await db.delete(
          _tableName,
          where: 'id = ? AND user_id = ?',
          whereArgs: [cardId, uid],
        );
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
        where: 'id = ? AND user_id = ?',
        whereArgs: [cardId, uid],
      );
    });
  }

  @override
  Future<List<CardDto>> getUnsyncedCards() {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND sync_status != ?',
        whereArgs: [uid, CardSyncStatus.synced.storageValue],
        orderBy: 'rowid ASC',
      );

      return rows.map(CardDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<void> markCardsSynced(List<CardDto> pushedCards) {
    if (pushedCards.isEmpty) {
      return Future<void>.value();
    }

    return _write((db, uid) async {
      final now = DateTime.now().toUtc().toIso8601String();
      for (final card in pushedCards) {
        // Matching updated_at leaves a Card changed since the snapshot dirty,
        // so its newer change is pushed by the next sync.
        const unchanged = 'id = ? AND user_id = ? AND updated_at = ?';
        final unchangedArgs = [
          card.id,
          uid,
          card.updatedAt?.toIso8601String() ?? '',
        ];

        if (card.syncStatus == CardSyncStatus.deleted) {
          await db.delete(
            _tableName,
            where: '$unchanged AND sync_status = ?',
            whereArgs: [...unchangedArgs, CardSyncStatus.deleted.storageValue],
          );
        } else {
          final updatedCount = await db.update(
            _tableName,
            <String, Object?>{
              'sync_status': CardSyncStatus.synced.storageValue,
              'last_synced_at': now,
              'deleted_at': null,
            },
            where: unchanged,
            whereArgs: unchangedArgs,
          );
          if (updatedCount == 0 && !await _rowExists(db, card.id)) {
            // A new Card deleted while its first push ran left no row, but
            // its copy now exists remotely. A tombstone lets the next sync
            // remove that copy.
            await db.insert(
              _tableName,
              CardDto(
                id: card.id,
                title: card.title,
                description: card.description,
                syncStatus: CardSyncStatus.deleted,
                updatedAt: DateTime.parse(now),
                deletedAt: DateTime.parse(now),
                userId: uid,
              ).toDatabaseRow(),
            );
          }
        }
      }
    });
  }

  /// Runs [action] as a plain read once the signed-in Account has adopted;
  /// until then, inside the adopting transaction.
  Future<T> _read<T>(
    Future<T> Function(AppDatabaseReadExecutor db, String uid) action,
  ) async {
    final uid = _sessionHolder.uid;
    if (uid == _adoptedUid) {
      return await _database.read((db) => action(db, uid));
    }

    return await _write(action);
  }

  Future<T> _write<T>(
    Future<T> Function(AppDatabaseWriteExecutor db, String uid) action,
  ) async {
    final uid = _sessionHolder.uid;
    final needsAdoption = uid != _adoptedUid;
    final result = await _database.write((db) async {
      if (needsAdoption) {
        await _adopt(db, uid);
      }

      return await action(db, uid);
    });
    _adoptedUid = uid;

    return result;
  }

  /// Gives every unowned Card to [uid] as never synced. Nothing unowned was
  /// ever pushed, so a tombstone has nothing left to delete remotely.
  Future<void> _adopt(AppDatabaseWriteExecutor db, String uid) async {
    await db.delete(
      _tableName,
      where: 'user_id IS NULL AND sync_status = ?',
      whereArgs: [CardSyncStatus.deleted.storageValue],
    );
    await db.update(_tableName, <String, Object?>{
      'user_id': uid,
      'sync_status': CardSyncStatus.created.storageValue,
      'last_synced_at': null,
    }, where: 'user_id IS NULL');
  }

  /// Whether any row, whoever owns it, has [cardId]. Ids are the table's
  /// primary key across every Account.
  Future<bool> _rowExists(AppDatabaseReadExecutor db, String cardId) async {
    final rows = await db.query(
      _tableName,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [cardId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<CardDto?> _getCardByIdIncludingDeleted(
    AppDatabaseReadExecutor db,
    String uid,
    String cardId,
  ) async {
    final rows = await db.query(
      _tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [cardId, uid],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CardDto.fromDatabaseRow(rows.single);
  }
}
