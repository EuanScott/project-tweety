import 'package:sqflite/sqflite.dart';

abstract final class AppDatabaseMigrations {
  static const latestVersion = 1;

  static Future<void> migrate(
    DatabaseExecutor db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      switch (version) {
        case 1:
          await _createV1(db);
        default:
          throw StateError('Missing database migration for version $version');
      }
    }
  }

  static Future<void> _createV1(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    for (var index = 0; index < 10; index++) {
      final cardNumber = index + 1;
      await db.insert('cards', <String, Object?>{
        'id': 'card-$cardNumber',
        'title': 'Card Title $cardNumber',
        'description':
            'This is the body copy for card number $cardNumber. '
            'You can replace this with whatever description you want.',
      });
    }
  }
}
