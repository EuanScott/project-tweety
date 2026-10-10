import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/core/storage/app_database_migrations.storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('AppDatabaseMigrations', () {
    late Directory temporaryDirectory;
    late AppDatabase database;

    setUpAll(sqfliteFfiInit);

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'project_tweety_database_migrations_',
      );
      database = SqfliteAppDatabase.test(
        databaseFactory: databaseFactoryFfi,
        databasePath: '${temporaryDirectory.path}/project_tweety.db',
      );
    });

    tearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test(
      'creates the latest cards schema with no Cards on first open',
      () async {
        final snapshot = await database.read((db) async {
          final versionRows = await db.rawQuery('PRAGMA user_version');
          final columnRows = await db.rawQuery('PRAGMA table_info(cards)');
          final indexRows = await db.rawQuery(
            "SELECT sql FROM sqlite_master WHERE type = 'index' "
            "AND tbl_name = 'cards' AND sql IS NOT NULL",
          );
          final cards = await db.query('cards');

          return (
            version: versionRows.single['user_version'],
            columns: columnRows.map((row) => row['name']).toList(),
            indexes: indexRows.map((row) => row['sql']).toList(),
            cards: cards,
          );
        });

        expect(snapshot.version, AppDatabaseMigrations.latestVersion);
        expect(snapshot.columns, <Object?>[
          'id',
          'title',
          'description',
          'sync_status',
          'updated_at',
          'last_synced_at',
          'deleted_at',
          'user_id',
        ]);
        expect(snapshot.indexes, [contains('cards(user_id)')]);
        expect(snapshot.cards, isEmpty);
      },
    );
  });
}
