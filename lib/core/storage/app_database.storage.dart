import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

import 'app_database_migrations.storage.dart';

abstract class AppDatabase {
  Future<T> read<T>(Future<T> Function(AppDatabaseReadExecutor db) action);

  Future<T> write<T>(Future<T> Function(AppDatabaseWriteExecutor db) action);

  Future<void> close();
}

abstract class AppDatabaseReadExecutor {
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
}

abstract class AppDatabaseWriteExecutor extends AppDatabaseReadExecutor {
  Future<void> execute(String sql, [List<Object?>? arguments]);

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    sqflite.ConflictAlgorithm? conflictAlgorithm,
  });

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    sqflite.ConflictAlgorithm? conflictAlgorithm,
  });

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});
}

@LazySingleton(as: AppDatabase)
class SqfliteAppDatabase implements AppDatabase {
  SqfliteAppDatabase()
    : _databaseFactory = sqflite.databaseFactory,
      _databasePath = null;

  SqfliteAppDatabase.test({
    required sqflite.DatabaseFactory databaseFactory,
    required String databasePath,
  }) : _databaseFactory = databaseFactory,
       _databasePath = databasePath;

  final sqflite.DatabaseFactory _databaseFactory;
  final String? _databasePath;

  Future<sqflite.Database>? _databaseFuture;
  Future<void>? _closingFuture;
  int _activeOperationCount = 0;
  Completer<void>? _operationsDrained;

  @override
  Future<T> read<T>(Future<T> Function(AppDatabaseReadExecutor db) action) {
    return _runOperation((database) {
      return action(_SqfliteAppDatabaseExecutor(database));
    });
  }

  @override
  Future<T> write<T>(Future<T> Function(AppDatabaseWriteExecutor db) action) {
    return _runOperation((database) {
      return database.transaction((transaction) {
        return action(_SqfliteAppDatabaseExecutor(transaction));
      });
    });
  }

  @override
  @disposeMethod
  Future<void> close() {
    final closingFuture = _closingFuture;
    if (closingFuture != null) {
      return closingFuture;
    }

    late final Future<void> newClosingFuture;
    newClosingFuture = _drainAndClose().whenComplete(() {
      if (identical(_closingFuture, newClosingFuture)) {
        _closingFuture = null;
      }
    });
    _closingFuture = newClosingFuture;
    return newClosingFuture;
  }

  Future<T> _runOperation<T>(
    Future<T> Function(sqflite.Database database) action,
  ) async {
    await _acquireOperation();
    try {
      final database = await _openDatabase();
      return await action(database);
    } finally {
      _releaseOperation();
    }
  }

  Future<void> _acquireOperation() async {
    while (true) {
      final closingFuture = _closingFuture;
      if (closingFuture != null) {
        await closingFuture;
        continue;
      }

      _activeOperationCount++;
      return;
    }
  }

  void _releaseOperation() {
    _activeOperationCount--;
    if (_activeOperationCount != 0) {
      return;
    }

    final operationsDrained = _operationsDrained;
    _operationsDrained = null;
    operationsDrained?.complete();
  }

  Future<void> _drainAndClose() async {
    await _waitForOperationsToDrain();

    final databaseFuture = _databaseFuture;
    _databaseFuture = null;
    if (databaseFuture == null) {
      return;
    }

    final database = await databaseFuture;
    await database.close();
  }

  Future<void> _waitForOperationsToDrain() {
    if (_activeOperationCount == 0) {
      return Future<void>.value();
    }

    return (_operationsDrained ??= Completer<void>()).future;
  }

  Future<sqflite.Database> _openDatabase() {
    final databaseFuture = _databaseFuture;
    if (databaseFuture != null) {
      return databaseFuture;
    }

    return _databaseFuture = _openAndResetOnFailure();
  }

  Future<sqflite.Database> _openAndResetOnFailure() async {
    try {
      return await _createDatabase();
    } catch (_) {
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<sqflite.Database> _createDatabase() async {
    final databasePath = _databasePath ?? await _defaultDatabasePath();
    return _databaseFactory.openDatabase(
      databasePath,
      options: sqflite.OpenDatabaseOptions(
        version: AppDatabaseMigrations.latestVersion,
        onCreate: (db, version) {
          return AppDatabaseMigrations.migrate(db, 0, version);
        },
        onUpgrade: (db, oldVersion, newVersion) {
          return AppDatabaseMigrations.migrate(db, oldVersion, newVersion);
        },
        onDowngrade: sqflite.onDatabaseVersionChangeError,
      ),
    );
  }

  Future<String> _defaultDatabasePath() async {
    final databasesPath = await sqflite.getDatabasesPath();
    return path.join(databasesPath, 'project_tweety.db');
  }
}

class _SqfliteAppDatabaseExecutor implements AppDatabaseWriteExecutor {
  const _SqfliteAppDatabaseExecutor(this._database);

  final sqflite.DatabaseExecutor _database;

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    return _database.execute(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    return _database.rawQuery(sql, arguments);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) {
    return _database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    sqflite.ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _database.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    sqflite.ConflictAlgorithm? conflictAlgorithm,
  }) {
    return _database.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    return _database.delete(table, where: where, whereArgs: whereArgs);
  }
}
