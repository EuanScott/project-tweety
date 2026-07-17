import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/core/storage/app_database_migrations.storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqfliteAppDatabase', () {
    setUpAll(sqfliteFfiInit);

    test('shares a pending database open between concurrent reads', () async {
      final factory = _ControlledOpenDatabaseFactory(databaseFactoryFfi);
      final database = SqfliteAppDatabase.test(
        databaseFactory: factory,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(database.close);

      final firstRead = database.read((db) => db.rawQuery('SELECT 1'));
      final secondRead = database.read((db) => db.rawQuery('SELECT 1'));

      try {
        await Future<void>.delayed(Duration.zero);
        expect(factory.openDatabaseCallCount, 1);
      } finally {
        factory.releaseOpen();
      }

      await Future.wait([firstRead, secondRead]);
    });

    test('retries after a database open fails', () async {
      final openError = StateError('open failed');
      final factory = _ControlledOpenDatabaseFactory(
        databaseFactoryFfi,
        firstOpenError: openError,
      );
      final database = SqfliteAppDatabase.test(
        databaseFactory: factory,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(database.close);

      final failedRead = database.read((db) => db.rawQuery('SELECT 1'));
      factory.releaseOpen();

      await expectLater(failedRead, throwsA(same(openError)));
      await database.read((db) => db.rawQuery('SELECT 1'));

      expect(factory.openDatabaseCallCount, 2);
    });

    test('rolls back a write when its action fails', () async {
      final database = SqfliteAppDatabase.test(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(database.close);
      final writeError = StateError('write failed');

      await expectLater(
        database.write<void>((db) async {
          await db.insert('cards', <String, Object?>{
            'id': 'rolled-back-card',
            'title': 'Rolled back',
            'description': 'This row must not be committed.',
          });
          throw writeError;
        }),
        throwsA(same(writeError)),
      );

      final rows = await database.read((db) {
        return db.query(
          'cards',
          where: 'id = ?',
          whereArgs: ['rolled-back-card'],
        );
      });

      expect(rows, isEmpty);
    });

    test(
      'close drains active reads and later reads reopen the database',
      () async {
        final factory = _ControlledOpenDatabaseFactory(databaseFactoryFfi)
          ..releaseOpen();
        final database = SqfliteAppDatabase.test(
          databaseFactory: factory,
          databasePath: inMemoryDatabasePath,
        );
        addTearDown(database.close);
        final activeReadStarted = Completer<void>();
        final releaseActiveRead = Completer<void>();
        final laterReadStarted = Completer<void>();

        final activeRead = database.read<void>((db) async {
          activeReadStarted.complete();
          await releaseActiveRead.future;
          await db.rawQuery('SELECT 1');
        });
        await activeReadStarted.future;

        var closeCompleted = false;
        final firstClose = database.close();
        unawaited(firstClose.then((_) => closeCompleted = true));
        final concurrentClose = database.close();
        final laterRead = database.read((db) {
          laterReadStarted.complete();
          return db.rawQuery('SELECT 1');
        });

        await Future<void>.delayed(Duration.zero);
        final closeCallsSharedFuture = identical(firstClose, concurrentClose);
        final closeWaitedForActiveRead = !closeCompleted;
        final laterReadWaitedForClose = !laterReadStarted.isCompleted;

        releaseActiveRead.complete();
        await activeRead;
        await Future.wait([firstClose, concurrentClose]);
        await laterRead;

        expect(closeCallsSharedFuture, isTrue);
        expect(closeWaitedForActiveRead, isTrue);
        expect(laterReadWaitedForClose, isTrue);
        expect(factory.openDatabaseCallCount, 2);
      },
    );

    test('close drains and persists an active write transaction', () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'project_tweety_database_persistence_',
      );
      final database = SqfliteAppDatabase.test(
        databaseFactory: databaseFactoryFfi,
        databasePath: '${temporaryDirectory.path}/project_tweety.db',
      );
      addTearDown(() async {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      });
      final writeStarted = Completer<void>();
      final releaseWrite = Completer<void>();

      final write = database.write<void>((db) async {
        await db.insert('cards', <String, Object?>{
          'id': 'persisted-card',
          'title': 'Persisted card',
          'description': 'Survives close and reopen.',
        });
        writeStarted.complete();
        await releaseWrite.future;
      });
      await writeStarted.future;

      var closeCompleted = false;
      final close = database.close();
      unawaited(close.then((_) => closeCompleted = true));
      await Future<void>.delayed(Duration.zero);
      final closeWaitedForWrite = !closeCompleted;

      releaseWrite.complete();
      await write;
      await close;

      final rows = await database.read((db) {
        return db.query(
          'cards',
          where: 'id = ?',
          whereArgs: ['persisted-card'],
        );
      });

      expect(closeWaitedForWrite, isTrue);
      expect(rows.single['title'], 'Persisted card');
    });

    test('rejects a newer file without downgrading its version', () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'project_tweety_database_downgrade_',
      );
      final databasePath = '${temporaryDirectory.path}/project_tweety.db';
      const newerVersion = AppDatabaseMigrations.latestVersion + 1;
      final newerDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(version: newerVersion),
      );
      await newerDatabase.close();
      final database = SqfliteAppDatabase.test(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(() async {
        await database.close();
        await temporaryDirectory.delete(recursive: true);
      });

      await expectLater(
        database.read((db) => db.rawQuery('SELECT 1')),
        throwsA(isA<ArgumentError>()),
      );

      final versionDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
      );
      try {
        final versionRows = await versionDatabase.rawQuery(
          'PRAGMA user_version',
        );
        expect(versionRows.single['user_version'], newerVersion);
      } finally {
        await versionDatabase.close();
      }
    });
  });
}

class _ControlledOpenDatabaseFactory implements DatabaseFactory {
  _ControlledOpenDatabaseFactory(this._delegate, {this.firstOpenError});

  final DatabaseFactory _delegate;
  final Object? firstOpenError;
  final Completer<void> _openGate = Completer<void>();

  int openDatabaseCallCount = 0;

  void releaseOpen() => _openGate.complete();

  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async {
    openDatabaseCallCount++;
    await _openGate.future;
    if (openDatabaseCallCount == 1 && firstOpenError != null) {
      throw firstOpenError!;
    }
    return _delegate.openDatabase(path, options: options);
  }

  @override
  Future<bool> databaseExists(String path) => _delegate.databaseExists(path);

  @override
  Future<void> deleteDatabase(String path) => _delegate.deleteDatabase(path);

  @override
  Future<String> getDatabasesPath() => _delegate.getDatabasesPath();

  @override
  Future<Uint8List> readDatabaseBytes(String path) {
    return _delegate.readDatabaseBytes(path);
  }

  @override
  Future<void> setDatabasesPath(String path) {
    return _delegate.setDatabasesPath(path);
  }

  @override
  Future<void> writeDatabaseBytes(String path, Uint8List bytes) {
    return _delegate.writeDatabaseBytes(path, bytes);
  }
}
