import 'package:sqflite/sqflite.dart';

abstract final class AppDatabaseMigrations {
  static const latestVersion = 5;
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
        case 4:
          await _addCardsOwnerV4(db);
        case 5:
          await _addCardsCreatedAtV5(db);
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
  static Future<void> _seedSampleCardsV3(DatabaseExecutor db) async {}

  // Nullable for good: tightening to NOT NULL needs a table rebuild in
  // SQLite. Rows already on the device stay unowned until Adoption.
  static Future<void> _addCardsOwnerV4(DatabaseExecutor db) async {
    await db.execute('ALTER TABLE cards ADD COLUMN user_id TEXT');
    await db.execute('CREATE INDEX cards_user_id ON cards(user_id)');
  }

  // Cards made before this column have no creation time, so their last
  // change stands in for it. A row never stamped by v2 stays empty.
  static Future<void> _addCardsCreatedAtV5(DatabaseExecutor db) async {
    await db.execute(
      "ALTER TABLE cards ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
    );
    await db.execute('UPDATE cards SET created_at = updated_at');
  }
}
