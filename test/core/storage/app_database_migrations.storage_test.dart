import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/core/storage/app_database_migrations.storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
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

  test('creates the latest cards schema and samples on first open', () async {
    final snapshot = await database.read((db) async {
      final versionRows = await db.rawQuery('PRAGMA user_version');
      final columnRows = await db.rawQuery('PRAGMA table_info(cards)');
      final cards = await db.query('cards', orderBy: 'rowid ASC');

      return (
        version: versionRows.single['user_version'],
        columns: columnRows.map((row) => row['name']).toList(),
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
    ]);
    expect(snapshot.cards, hasLength(10));
    expect(snapshot.cards.map((card) => card['id']), <String>[
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
    ]);
    expect(snapshot.cards.first, containsPair('id', 'card-1'));
    expect(snapshot.cards.last, containsPair('id', 'card-10'));
    expect(snapshot.cards, everyElement(containsPair('sync_status', 'synced')));
    final seedTimestamp = snapshot.cards.first['updated_at'];
    expect(
      seedTimestamp,
      isA<String>().having((value) => value, 'value', isNotEmpty),
    );
    expect(DateTime.parse(seedTimestamp! as String).isUtc, isTrue);
    expect(
      snapshot.cards,
      everyElement(
        allOf(
          containsPair('updated_at', seedTimestamp),
          containsPair('last_synced_at', seedTimestamp),
          containsPair('deleted_at', null),
        ),
      ),
    );
  });

  test('does not seed an existing v1 database again', () async {
    final initialCards = await database.read((db) {
      return db.query('cards', orderBy: 'rowid ASC');
    });

    await database.close();
    database = SqfliteAppDatabase.test(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${temporaryDirectory.path}/project_tweety.db',
    );

    final reopenedCards = await database.read((db) {
      return db.query('cards', orderBy: 'rowid ASC');
    });

    expect(reopenedCards, initialCards);
  });

  test('does not resurrect cards removed after initial creation', () async {
    await database.write((db) => db.delete('cards'));
    await database.close();
    database = SqfliteAppDatabase.test(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${temporaryDirectory.path}/project_tweety.db',
    );

    final reopenedCards = await database.read((db) => db.query('cards'));

    expect(reopenedCards, isEmpty);
  });
}
