import 'package:sqflite/sqflite.dart';

abstract final class AppDatabaseMigrations {
  static const latestVersion = 3;
  static const _syncedCardStatus = 'synced';

  static Future<void> migrate(
    DatabaseExecutor db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 1:
          await _createCardsV1(db);
        case 2:
          await _addCardsSyncMetadataV2(db);
        case 3:
          await _seedSampleCardsV3(db);
        default:
          throw StateError('Missing database migration for version $version');
      }
    }
  }

  static Future<void> _createCardsV1(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _addCardsSyncMetadataV2(DatabaseExecutor db) async {
    await db.execute(
      "ALTER TABLE cards ADD COLUMN sync_status TEXT NOT NULL DEFAULT '$_syncedCardStatus'",
    );
    await db.execute(
      "ALTER TABLE cards ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''",
    );
    await db.execute('ALTER TABLE cards ADD COLUMN last_synced_at TEXT');
    await db.execute('ALTER TABLE cards ADD COLUMN deleted_at TEXT');
  }

  // TODO: Research the discipline around rewriting an already-run migration.
  // ADR-0008 decides this seed is gutted to a no-op rather than deleted (the
  // `default:` branch throws for a missing version) or undone by a later
  // migration. That means a v3 database created by old code holds ten sample
  // cards while a v3 database created by new code holds none — same version,
  // different contents. Exempted here only because nothing has shipped. Find
  // out what the real options are (backfill-safe no-ops, squashing a baseline
  // schema, version floors) before relying on this trick again.
  static Future<void> _seedSampleCardsV3(DatabaseExecutor db) async {
    final countRows = await db.rawQuery('SELECT COUNT(*) AS count FROM cards');
    final count = countRows.single['count']! as int;
    if (count > 0) {
      return;
    }

    final seedTimestamp = DateTime.now().toUtc().toIso8601String();
    for (var index = 0; index < 10; index++) {
      final cardNumber = index + 1;
      await db.insert('cards', <String, Object?>{
        'id': 'card-$cardNumber',
        'title': 'Card Title $cardNumber',
        'description':
            'This is the body copy for card number $cardNumber. '
            'You can replace this with whatever description you want.',
        'sync_status': _syncedCardStatus,
        'updated_at': seedTimestamp,
        'last_synced_at': null,
        'deleted_at': null,
      });
    }
  }
}
