import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

/// Log entries stored on this device, scoped to the signed-in Account.
///
/// Before its first operation for an Account, it adopts every unowned log entry
/// in the same transaction as that operation, so nothing reads the table
/// before Adoption finishes.
@LazySingleton(as: LogsDataSource)
class LogsLocalDataSource(
  final AppDatabase _database,
  final SessionHolder _sessionHolder,
) implements LogsDataSource {
  /// The stored name predates the Logs rename and is kept
  /// ([ADR-0019](../../../../docs/decisions/0019-log-entries-keep-the-cards-storage-names.md)).
  static const _tableName = 'cards';

  String? _adoptedUid;

  @override
  Future<List<LogEntryDto>> getLogs() {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND sync_status != ?',
        whereArgs: [uid, LogEntrySyncStatus.deleted.storageValue],
        orderBy: 'created_at DESC, rowid DESC',
      );
      return rows.map(LogEntryDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<LogEntryDto?> getLogEntryById(String logEntryId) {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'id = ? AND user_id = ? AND sync_status != ?',
        whereArgs: [logEntryId, uid, LogEntrySyncStatus.deleted.storageValue],
        limit: 1,
      );

      if (rows.isEmpty) {
        return null;
      }

      return LogEntryDto.fromDatabaseRow(rows.single);
    });
  }

  @override
  Future<LogEntryDto> createLogEntry(LogEntryDto logEntry) {
    return _write((db, uid) async {
      final now = DateTime.now().toUtc();
      final createdLogEntry = LogEntryDto(
        id: logEntry.id,
        title: logEntry.title,
        description: logEntry.description,
        syncStatus: LogEntrySyncStatus.created,
        createdAt: now,
        updatedAt: now,
        userId: uid,
      );
      await db.insert(_tableName, createdLogEntry.toDatabaseRow());
      return createdLogEntry;
    });
  }

  @override
  Future<LogEntryDto?> updateLogEntry(LogEntryDto logEntry) {
    return _write((db, uid) async {
      final existingLogEntry = await _getLogEntryByIdIncludingDeleted(
        db,
        uid,
        logEntry.id,
      );
      if (existingLogEntry == null ||
          existingLogEntry.syncStatus == LogEntrySyncStatus.deleted) {
        return null;
      }

      final now = DateTime.now().toUtc();
      final syncStatus =
          existingLogEntry.syncStatus == LogEntrySyncStatus.created
          ? LogEntrySyncStatus.created
          : LogEntrySyncStatus.updated;

      final updatedLogEntry = LogEntryDto(
        id: logEntry.id,
        title: logEntry.title,
        description: logEntry.description,
        syncStatus: syncStatus,
        createdAt: existingLogEntry.createdAt,
        updatedAt: now,
        lastSyncedAt: existingLogEntry.lastSyncedAt,
        deletedAt: null,
        userId: uid,
      );
      await db.update(
        _tableName,
        updatedLogEntry.toDatabaseRow(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [logEntry.id, uid],
      );
      return updatedLogEntry;
    });
  }

  @override
  Future<void> deleteLogEntry(String logEntryId) {
    return _write((db, uid) async {
      final existingLogEntry = await _getLogEntryByIdIncludingDeleted(
        db,
        uid,
        logEntryId,
      );
      if (existingLogEntry == null) {
        return;
      }

      if (existingLogEntry.syncStatus == LogEntrySyncStatus.created) {
        await db.delete(
          _tableName,
          where: 'id = ? AND user_id = ?',
          whereArgs: [logEntryId, uid],
        );
        return;
      }

      final now = DateTime.now().toUtc();
      await db.update(
        _tableName,
        <String, Object?>{
          'sync_status': LogEntrySyncStatus.deleted.storageValue,
          'updated_at': now.toIso8601String(),
          'deleted_at': now.toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [logEntryId, uid],
      );
    });
  }

  @override
  Future<List<LogEntryDto>> getUnsyncedLogs() {
    return _read((db, uid) async {
      final rows = await db.query(
        _tableName,
        where: 'user_id = ? AND sync_status != ?',
        whereArgs: [uid, LogEntrySyncStatus.synced.storageValue],
        orderBy: 'rowid ASC',
      );

      return rows.map(LogEntryDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<void> markLogsSynced(List<LogEntryDto> pushedLogs) {
    if (pushedLogs.isEmpty) {
      return Future<void>.value();
    }

    return _write((db, uid) async {
      final now = DateTime.now().toUtc().toIso8601String();
      for (final logEntry in pushedLogs) {
        // Matching updated_at leaves a log entry changed since the snapshot dirty,
        // so its newer change is pushed by the next sync.
        const unchanged = 'id = ? AND user_id = ? AND updated_at = ?';
        final unchangedArgs = [
          logEntry.id,
          uid,
          logEntry.updatedAt?.toIso8601String() ?? '',
        ];

        if (logEntry.syncStatus == LogEntrySyncStatus.deleted) {
          await db.delete(
            _tableName,
            where: '$unchanged AND sync_status = ?',
            whereArgs: [
              ...unchangedArgs,
              LogEntrySyncStatus.deleted.storageValue,
            ],
          );
        } else {
          final updatedCount = await db.update(
            _tableName,
            <String, Object?>{
              'sync_status': LogEntrySyncStatus.synced.storageValue,
              'last_synced_at': now,
              'deleted_at': null,
            },
            where: unchanged,
            whereArgs: unchangedArgs,
          );
          if (updatedCount == 0 && !await _rowExists(db, logEntry.id)) {
            // A new log entry deleted while its first push ran left no row, but
            // its copy now exists remotely. A tombstone lets the next sync
            // remove that copy.
            await db.insert(
              _tableName,
              LogEntryDto(
                id: logEntry.id,
                title: logEntry.title,
                description: logEntry.description,
                syncStatus: LogEntrySyncStatus.deleted,
                createdAt: logEntry.createdAt,
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

  /// Gives every unowned log entry to [uid] as never synced. Nothing unowned was
  /// ever pushed, so a tombstone has nothing left to delete remotely.
  Future<void> _adopt(AppDatabaseWriteExecutor db, String uid) async {
    await db.delete(
      _tableName,
      where: 'user_id IS NULL AND sync_status = ?',
      whereArgs: [LogEntrySyncStatus.deleted.storageValue],
    );
    await db.update(_tableName, <String, Object?>{
      'user_id': uid,
      'sync_status': LogEntrySyncStatus.created.storageValue,
      'last_synced_at': null,
    }, where: 'user_id IS NULL');
  }

  /// Whether any row, whoever owns it, has [logEntryId]. Ids are the table's
  /// primary key across every Account.
  Future<bool> _rowExists(AppDatabaseReadExecutor db, String logEntryId) async {
    final rows = await db.query(
      _tableName,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [logEntryId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<LogEntryDto?> _getLogEntryByIdIncludingDeleted(
    AppDatabaseReadExecutor db,
    String uid,
    String logEntryId,
  ) async {
    final rows = await db.query(
      _tableName,
      where: 'id = ? AND user_id = ?',
      whereArgs: [logEntryId, uid],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return LogEntryDto.fromDatabaseRow(rows.single);
  }
}
