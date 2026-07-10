import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

@LazySingleton(as: CardsDataSource)
class CardsLocalDataSource implements CardsDataSource {
  const CardsLocalDataSource(this._database);

  static const _tableName = 'cards';

  final AppDatabase _database;

  @override
  Future<List<CardDto>> getCards() {
    return _database.read((db) async {
      final rows = await db.query(_tableName, orderBy: 'rowid ASC');
      return rows.map(CardDto.fromDatabaseRow).toList(growable: false);
    });
  }

  @override
  Future<CardDto?> getCardById(String cardId) {
    return _database.read((db) async {
      final rows = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [cardId],
        limit: 1,
      );

      if (rows.isEmpty) {
        return null;
      }

      return CardDto.fromDatabaseRow(rows.single);
    });
  }
}
