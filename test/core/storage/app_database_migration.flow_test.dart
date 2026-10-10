import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/core/storage/app_database_migrations.storage.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/fake_session_holder.dart';

void main() {
  group('AppDatabase migrations', () {
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

    test(
      'opening a v1 database preserves rows and adds sync metadata',
      () async {
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
          'user_id': null,
          'created_at': '',
        });
      },
    );

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
        expect(snapshot.columns, contains('user_id'));
        expect(snapshot.cards, <Map<String, Object?>>[
          {
            ...existingCard,
            'user_id': null,
            'created_at': existingCard['updated_at'],
          },
        ]);
      },
    );

    test('an empty v2 database stays empty', () async {
      await _createV2Database(databasePath);

      final database = openAppDatabase();
      final cards = await database.read((db) => db.query('cards'));

      expect(cards, isEmpty);
    });

    test('opening a v3 database keeps every row unowned and its sync state '
        'untouched', () async {
      final existingCards = [
        for (final status in ['synced', 'created', 'updated', 'deleted'])
          <String, Object?>{
            'id': '$status-card',
            'title': 'A $status card',
            'description': 'Created by schema version 3',
            'sync_status': status,
            'updated_at': '2026-07-01T12:00:00.000Z',
            'last_synced_at': null,
            'deleted_at': status == 'deleted'
                ? '2026-07-02T12:00:00.000Z'
                : null,
          },
      ];
      await _createMigratedDatabase(
        databasePath,
        version: 3,
        existingCards: existingCards,
      );

      final database = openAppDatabase();
      final snapshot = await database.read((db) async {
        final versionRows = await db.rawQuery('PRAGMA user_version');
        final cards = await db.query('cards', orderBy: 'rowid ASC');
        return (version: versionRows.single['user_version'], cards: cards);
      });

      expect(snapshot.version, AppDatabaseMigrations.latestVersion);
      expect(snapshot.cards, [
        for (final card in existingCards)
          {...card, 'user_id': null, 'created_at': card['updated_at']},
      ]);
    });

    test(
      'the first signed-in Account adopts the rows of a migrated v3 database',
      () async {
        await _createMigratedDatabase(
          databasePath,
          version: 3,
          existingCards: [
            <String, Object?>{
              'id': 'card-1',
              'title': 'Card Title 1',
              'description': 'Seeded by the old version 3',
              'sync_status': 'synced',
              'updated_at': '2026-07-01T12:00:00.000Z',
              'last_synced_at': null,
              'deleted_at': null,
            },
          ],
        );

        final database = openAppDatabase();
        final cards = await CardsLocalDataSource(
          database,
          FakeSessionHolder('first-account'),
        ).getCards();
        final rows = await database.read((db) => db.query('cards'));

        expect(cards.single.id, 'card-1');
        expect(
          rows.single,
          allOf(
            containsPair('user_id', 'first-account'),
            containsPair('sync_status', 'created'),
          ),
        );
      },
    );

    test(
      'opening a v4 database dates each Card from its last change',
      () async {
        await _createMigratedDatabase(
          databasePath,
          version: 4,
          existingCards: [
            <String, Object?>{
              'id': 'dated-card',
              'title': 'Dated card',
              'description': 'Changed before created_at existed',
              'sync_status': 'synced',
              'updated_at': '2026-07-01T12:00:00.000Z',
              'user_id': 'first-account',
            },
            <String, Object?>{
              'id': 'undated-card',
              'title': 'Undated card',
              'description': 'Never stamped by schema version 2',
              'sync_status': 'synced',
              'updated_at': '',
              'user_id': 'first-account',
            },
          ],
        );

        final database = openAppDatabase();
        final rows = await database.read(
          (db) => db.query('cards', orderBy: 'rowid ASC'),
        );

        expect(rows.map((row) => row['created_at']), [
          '2026-07-01T12:00:00.000Z',
          '',
        ]);
      },
    );
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

Future<void> _createMigratedDatabase(
  String databasePath, {
  required int version,
  required List<Map<String, Object?>> existingCards,
}) async {
  final database = await databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      version: version,
      onCreate: (db, version) async {
        await AppDatabaseMigrations.migrate(db, 0, version);
        for (final card in existingCards) {
          await db.insert('cards', card);
        }
      },
    ),
  );
  await database.close();
}
