import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/core/storage/app_database_migrations.storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late String databasePath;
  late List<AppDatabase> openedDatabases;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'project_tweety_migration_integration_test_',
    );
    databasePath = '${temporaryDirectory.path}/project_tweety.db';
    openedDatabases = [];
  });

  tearDown(() async {
    for (final database in openedDatabases.reversed) {
      await database.close();
    }
    await temporaryDirectory.delete(recursive: true);
  });

  AppDatabase openAppDatabase() {
    final database = SqfliteAppDatabase.test(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    openedDatabases.add(database);
    return database;
  }

  test('opening a v1 database preserves rows and adds sync metadata', () async {
    const existingCard = <String, Object?>{
      'id': 'foundation-card',
      'title': 'Foundation card',
      'description': 'Created by schema version 1',
    };
    await _createV1Database(databasePath, existingCard: existingCard);

    final database = openAppDatabase();
    final snapshot = await database.read((db) async {
      final versionRows = await db.rawQuery('PRAGMA user_version');
      final cards = await db.query('cards');
      return (version: versionRows.single['user_version'], cards: cards);
    });

    expect(snapshot.version, AppDatabaseMigrations.latestVersion);
    expect(snapshot.cards, hasLength(1));
    expect(snapshot.cards.single, <String, Object?>{
      ...existingCard,
      'sync_status': 'synced',
      'updated_at': '',
      'last_synced_at': null,
      'deleted_at': null,
    });
  });

  test(
    'opening a v2 database migrates it and preserves existing rows',
    () async {
      const existingCard = <String, Object?>{
        'id': 'legacy-card',
        'title': 'Legacy card',
        'description': 'Created before the latest migration',
        'sync_status': 'updated',
        'updated_at': '2026-07-01T12:00:00.000Z',
        'last_synced_at': '2026-06-30T12:00:00.000Z',
        'deleted_at': null,
      };
      await _createV2Database(databasePath, existingCard: existingCard);

      final database = openAppDatabase();
      final snapshot = await database.read((db) async {
        final versionRows = await db.rawQuery('PRAGMA user_version');
        final columnRows = await db.rawQuery('PRAGMA table_info(cards)');
        final cards = await db.query('cards');

        return (
          version: versionRows.single['user_version'],
          columns: columnRows.map((row) => row['name']).toSet(),
          cards: cards,
        );
      });

      expect(snapshot.version, AppDatabaseMigrations.latestVersion);
      expect(
        snapshot.columns,
        containsAll(<String>{
          'id',
          'title',
          'description',
          'sync_status',
          'updated_at',
          'last_synced_at',
          'deleted_at',
        }),
      );
      expect(snapshot.cards, <Map<String, Object?>>[existingCard]);
    },
  );

  test('an empty v2 database receives sample cards exactly once', () async {
    await _createV2Database(databasePath);

    final firstDatabase = openAppDatabase();
    final firstCards = await firstDatabase.read((db) {
      return db.query('cards', orderBy: 'id ASC');
    });

    expect(firstCards, hasLength(10));
    expect(firstCards.map((card) => card['id']).toSet(), <String>{
      'card-1',
      'card-2',
      'card-3',
      'card-4',
      'card-5',
      'card-6',
      'card-7',
      'card-8',
      'card-9',
      'card-10',
    });

    await firstDatabase.close();
    openedDatabases.remove(firstDatabase);

    final reopenedDatabase = openAppDatabase();
    final cardsAfterReopen = await reopenedDatabase.read((db) {
      return db.query('cards', orderBy: 'id ASC');
    });

    expect(cardsAfterReopen, firstCards);
  });

  test('deleted sample cards stay absent after reopening', () async {
    await _createV2Database(databasePath);

    final firstDatabase = openAppDatabase();
    final seededCards = await firstDatabase.read((db) => db.query('cards'));
    expect(seededCards, hasLength(10));

    await firstDatabase.write((db) => db.delete('cards'));
    await firstDatabase.close();
    openedDatabases.remove(firstDatabase);

    final reopenedDatabase = openAppDatabase();
    final cardsAfterReopen = await reopenedDatabase.read((db) {
      return db.query('cards');
    });

    expect(cardsAfterReopen, isEmpty);
  });
}

Future<void> _createV1Database(
  String databasePath, {
  required Map<String, Object?> existingCard,
}) async {
  final database = await databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE cards (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL
          )
        ''');
        await db.insert('cards', existingCard);
      },
    ),
  );
  await database.close();
}

Future<void> _createV2Database(
  String databasePath, {
  Map<String, Object?>? existingCard,
}) async {
  final database = await databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE cards (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'synced',
            updated_at TEXT NOT NULL DEFAULT '',
            last_synced_at TEXT,
            deleted_at TEXT
          )
        ''');
        if (existingCard != null) {
          await db.insert('cards', existingCard);
        }
      },
    ),
  );
  await database.close();
}
