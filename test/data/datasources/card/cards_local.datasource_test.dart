import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;
  late CardsDataSource dataSource;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'project_tweety_cards_local_datasource_',
    );
    database = SqfliteAppDatabase.test(
      databaseFactory: databaseFactoryFfi,
      databasePath: '${temporaryDirectory.path}/project_tweety.db',
    );
    dataSource = CardsLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('returns stored cards in insertion order', () async {
    final cards = await dataSource.getCards();

    expect(cards.map((card) => card.id), <String>[
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
    expect(cards.first.title, 'Card Title 1');
    expect(
      cards.first.description,
      'This is the body copy for card number 1. '
      'You can replace this with whatever description you want.',
    );
  });

  test('returns a stored card by id', () async {
    final card = await dataSource.getCardById('card-7');

    expect(card?.id, 'card-7');
    expect(card?.title, 'Card Title 7');
  });

  test('returns null when a parameterized card id is missing', () async {
    final card = await dataSource.getCardById('card-1\' OR 1 = 1 --');

    expect(card, isNull);
  });
}
