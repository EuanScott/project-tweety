import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.service.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_firestore.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

import '../../../support/fake_session_holder.dart';

void main() {
  late _FakeFirestore firestore;
  late FakeSessionHolder sessionHolder;
  late _RecordingErrorReportingService errorReporting;

  FirestoreLogsRemoteDataSource buildDataSource() =>
      FirestoreLogsRemoteDataSource(
        firestore,
        sessionHolder,
        ErrorReportingFacade([errorReporting]),
      );

  setUp(() {
    firestore = _FakeFirestore();
    sessionHolder = FakeSessionHolder('account-a');
    errorReporting = _RecordingErrorReportingService();
  });

  group('FirestoreLogsRemoteDataSource', () {
    test('writes a created or edited log entry as its title, description, '
        'createdAt and updatedAt under the Account', () async {
      final outcomes = await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.created),
        _logEntry('card-2', LogEntrySyncStatus.updated),
      ]);

      expect(outcomes, {
        'card-1': LogEntryPushOutcome.confirmed,
        'card-2': LogEntryPushOutcome.confirmed,
      });
      expect(firestore.writes, {
        'users/account-a/cards/card-1': {
          'title': 'Title card-1',
          'description': 'Body card-1',
          'createdAt': Timestamp.fromDate(_createdAt),
          'updatedAt': Timestamp.fromDate(_updatedAt),
        },
        'users/account-a/cards/card-2': {
          'title': 'Title card-2',
          'description': 'Body card-2',
          'createdAt': Timestamp.fromDate(_createdAt),
          'updatedAt': Timestamp.fromDate(_updatedAt),
        },
      });
    });

    test('writes exactly the fields firestore.rules accepts', () async {
      await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.created),
      ]);

      final written = firestore.writes['users/account-a/cards/card-1']!.keys;
      final rules = File('firestore.rules').readAsStringSync();
      final allowed = RegExp(r'hasOnly\(\[([^\]]*)\]\)')
          .firstMatch(rules)!
          .group(1)!
          .split(',')
          .map((field) => field.trim().replaceAll("'", ''))
          .toSet();

      expect(written.toSet(), {
        'title',
        'description',
        'createdAt',
        'updatedAt',
      });
      expect(allowed, written.toSet());
      expect(rules, contains('card.createdAt is timestamp'));
    });

    test(
      'dates a log entry with no creation time from its last change',
      () async {
        await buildDataSource().pushLogs([
          LogEntryDto(
            id: 'card-1',
            title: 'Title card-1',
            description: 'Body card-1',
            syncStatus: LogEntrySyncStatus.updated,
            updatedAt: _updatedAt,
          ),
        ]);

        expect(
          firestore.writes['users/account-a/cards/card-1'],
          containsPair('createdAt', Timestamp.fromDate(_updatedAt)),
        );
      },
    );

    test('deletes the document for a tombstone', () async {
      final outcomes = await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.deleted),
      ]);

      expect(outcomes, {'card-1': LogEntryPushOutcome.confirmed});
      expect(firestore.deletes, ['users/account-a/cards/card-1']);
      expect(firestore.writes, isEmpty);
    });

    test('reports each log entry as its write settles', () async {
      final pushed = <(String, LogEntryPushOutcome)>[];
      firestore.errors['users/account-a/cards/card-2'] = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );

      await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.created),
        _logEntry('card-2', LogEntrySyncStatus.created),
      ], onPushed: (logEntryId, outcome) => pushed.add((logEntryId, outcome)));

      expect(
        pushed,
        unorderedEquals([
          ('card-1', LogEntryPushOutcome.confirmed),
          ('card-2', LogEntryPushOutcome.failure),
        ]),
      );
    });

    test('a refused write is a failure for that log entry only, and is '
        'reported with its code', () async {
      final error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      firestore.errors['users/account-a/cards/card-2'] = error;

      final outcomes = await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.created),
        _logEntry('card-2', LogEntrySyncStatus.created),
      ]);

      expect(outcomes, {
        'card-1': LogEntryPushOutcome.confirmed,
        'card-2': LogEntryPushOutcome.failure,
      });
      expect(errorReporting.errors, [error]);
      expect(errorReporting.codes, ['permission-denied']);
    });

    test('an unavailable server is a network failure and is not '
        'reported', () async {
      firestore.errors['users/account-a/cards/card-1'] = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

      final outcomes = await buildDataSource().pushLogs([
        _logEntry('card-1', LogEntrySyncStatus.created),
      ]);

      expect(outcomes, {'card-1': LogEntryPushOutcome.networkFailure});
      expect(errorReporting.errors, isEmpty);
    });

    test('a write the server never confirms is a network failure after '
        '10 seconds', () {
      fakeAsync((async) {
        firestore.hanging.add('users/account-a/cards/card-1');
        Map<String, LogEntryPushOutcome>? outcomes;
        unawaited(
          buildDataSource()
              .pushLogs([
                _logEntry('card-1', LogEntrySyncStatus.created),
                _logEntry('card-2', LogEntrySyncStatus.created),
              ])
              .then((value) => outcomes = value),
        );

        async.elapse(const Duration(milliseconds: 9999));
        expect(outcomes, isNull);

        async.elapse(const Duration(milliseconds: 1));
        expect(outcomes, {
          'card-1': LogEntryPushOutcome.networkFailure,
          'card-2': LogEntryPushOutcome.confirmed,
        });
      });
    });

    test('never has more than the write limit in flight, and still gives every '
        'log entry its outcome', () {
      fakeAsync((async) {
        firestore.writeDelay = const Duration(seconds: 1);
        const count = 45;
        final pushed = <String>[];
        Map<String, LogEntryPushOutcome>? outcomes;
        unawaited(
          buildDataSource()
              .pushLogs([
                for (var i = 0; i < count; i++)
                  _logEntry('card-$i', LogEntrySyncStatus.created),
              ], onPushed: (logEntryId, _) => pushed.add(logEntryId))
              .then((value) => outcomes = value),
        );

        async.elapse(const Duration(seconds: 1));
        expect(
          firestore.inFlight,
          FirestoreLogsRemoteDataSource.maxConcurrentWrites,
        );
        async.elapse(const Duration(seconds: 10));

        expect(
          firestore.peakInFlight,
          FirestoreLogsRemoteDataSource.maxConcurrentWrites,
        );
        expect(outcomes, hasLength(count));
        expect(outcomes!.values, everyElement(LogEntryPushOutcome.confirmed));
        expect(pushed, hasLength(count));
      });
    });

    test('a queued write gets its full timeout from when it starts', () {
      fakeAsync((async) {
        firestore.writeDelay = const Duration(seconds: 6);
        Map<String, LogEntryPushOutcome>? outcomes;
        unawaited(
          buildDataSource()
              .pushLogs([
                for (var i = 0; i < 20; i++)
                  _logEntry('card-$i', LogEntrySyncStatus.created),
              ])
              .then((value) => outcomes = value),
        );

        async.elapse(const Duration(seconds: 12));

        expect(outcomes, hasLength(20));
        expect(outcomes!.values, everyElement(LogEntryPushOutcome.confirmed));
      });
    });

    test('fails when nobody is signed in', () async {
      sessionHolder.signedInUid = null;

      await expectLater(
        buildDataSource().pushLogs([
          _logEntry('card-1', LogEntrySyncStatus.created),
        ]),
        throwsA(isA<AccountNotSignedInException>()),
      );
      expect(firestore.writes, isEmpty);
    });
  });

  group('FirestoreLogsRemoteDataSource download', () {
    test('reads every document of the Account from the server as a synced '
        'log entry of that Account', () async {
      firestore.documents['users/account-a/cards'] = {
        'card-1': {
          'title': 'Title card-1',
          'description': 'Body card-1',
          'createdAt': Timestamp.fromDate(_createdAt),
          'updatedAt': Timestamp.fromDate(_updatedAt),
        },
      };

      final logs = await buildDataSource().fetchLogs();

      expect(firestore.readSources, [Source.server]);
      expect(logs, hasLength(1));
      final logEntry = logs.single;
      expect(logEntry.id, 'card-1');
      expect(logEntry.title, 'Title card-1');
      expect(logEntry.description, 'Body card-1');
      expect(logEntry.createdAt, _createdAt);
      expect(logEntry.updatedAt, _updatedAt);
      expect(logEntry.syncStatus, LogEntrySyncStatus.synced);
      expect(logEntry.userId, 'account-a');
    });

    test(
      'dates a document with no creation time from its last change',
      () async {
        firestore.documents['users/account-a/cards'] = {
          'card-1': {
            'title': 'Title card-1',
            'description': 'Body card-1',
            'updatedAt': Timestamp.fromDate(_updatedAt),
          },
        };

        final logs = await buildDataSource().fetchLogs();

        expect(logs.single.createdAt, _updatedAt);
      },
    );

    test('skips and reports a document it cannot read, and keeps the '
        'rest', () async {
      firestore.documents['users/account-a/cards'] = {
        'card-1': {'title': 'No body', 'updatedAt': Timestamp.now()},
        'card-2': {
          'title': 'Title card-2',
          'description': 'Body card-2',
          'createdAt': Timestamp.fromDate(_createdAt),
          'updatedAt': Timestamp.fromDate(_updatedAt),
        },
      };

      final logs = await buildDataSource().fetchLogs();

      expect(logs.map((logEntry) => logEntry.id), ['card-2']);
      expect(errorReporting.errors, [isA<FormatException>()]);
    });

    test('an unavailable server is an unreachable Account and is not '
        'reported', () async {
      firestore.readError = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );

      await expectLater(
        buildDataSource().fetchLogs(),
        throwsA(isA<LogsAccountUnreachableException>()),
      );
      expect(errorReporting.errors, isEmpty);
    });

    test('a read the server never answers is an unreachable Account after '
        '30 seconds', () {
      fakeAsync((async) {
        firestore.readHangs = true;
        Object? error;
        unawaited(
          buildDataSource().fetchLogs().then<void>(
            (_) {},
            onError: (Object e) => error = e,
          ),
        );

        async.elapse(const Duration(seconds: 29));
        expect(error, isNull);

        async.elapse(const Duration(seconds: 1));
        expect(error, isA<LogsAccountUnreachableException>());
      });
    });

    test('a refused read fails with the server error', () async {
      final refusal = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      firestore.readError = refusal;

      await expectLater(buildDataSource().fetchLogs(), throwsA(refusal));
    });

    test('fails when nobody is signed in', () async {
      sessionHolder.signedInUid = null;

      await expectLater(
        buildDataSource().fetchLogs(),
        throwsA(isA<AccountNotSignedInException>()),
      );
      expect(firestore.readSources, isEmpty);
    });
  });
}

final _createdAt = DateTime.utc(2026, 10, 1, 9);
final _updatedAt = DateTime.utc(2026, 10, 9, 12);

LogEntryDto _logEntry(String id, LogEntrySyncStatus status) => LogEntryDto(
  id: id,
  title: 'Title $id',
  description: 'Body $id',
  syncStatus: status,
  createdAt: _createdAt,
  updatedAt: _updatedAt,
);

class _FakeFirestore extends Fake implements FirebaseFirestore {
  final writes = <String, Map<String, dynamic>>{};
  final deletes = <String>[];
  final errors = <String, Exception>{};
  final hanging = <String>{};
  Duration writeDelay = Duration.zero;
  int inFlight = 0;
  int peakInFlight = 0;

  final documents = <String, Map<String, Map<String, dynamic>>>{};
  final readSources = <Source>[];
  Exception? readError;
  bool readHangs = false;

  @override
  DocumentReference<Map<String, dynamic>> doc(String documentPath) =>
      _FakeDocumentReference(this, documentPath);

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _FakeCollectionReference(this, collectionPath);
}

// The SDK marks these query types @sealed for app code; faking them is the
// only way to drive a read without a server.
// ignore: subtype_of_sealed_class
class _FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  new(this._firestore, this._path);

  final _FakeFirestore _firestore;
  final String _path;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    _firestore.readSources.add(options?.source ?? Source.serverAndCache);
    if (_firestore.readHangs) {
      await Completer<void>().future;
    }
    if (_firestore.readError case final error?) {
      throw error;
    }

    return _FakeQuerySnapshot([
      for (final MapEntry(:key, :value)
          in (_firestore.documents[_path] ?? const {}).entries)
        _FakeQueryDocumentSnapshot(key, value),
    ]);
  }
}

class _FakeQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  new(this.docs);

  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

// QueryDocumentSnapshot is @sealed for app code too.
// ignore: subtype_of_sealed_class
class _FakeQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  new(this.id, this._data);

  @override
  final String id;
  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic> data() => _data;
}

// The SDK marks DocumentReference @sealed for app code; faking it here is the
// only way to drive a per-write timeout without a server.
// ignore: subtype_of_sealed_class
class _FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  new(this._firestore, this._path);

  final _FakeFirestore _firestore;
  final String _path;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    await _settle();
    _firestore.writes[_path] = data;
  }

  @override
  Future<void> delete() async {
    await _settle();
    _firestore.deletes.add(_path);
  }

  Future<void> _settle() async {
    _firestore
      ..inFlight += 1
      ..peakInFlight = max(_firestore.peakInFlight, _firestore.inFlight);
    try {
      await _settleWrite();
    } finally {
      _firestore.inFlight -= 1;
    }
  }

  Future<void> _settleWrite() async {
    if (_firestore.writeDelay > Duration.zero) {
      await Future<void>.delayed(_firestore.writeDelay);
    }
    if (_firestore.hanging.contains(_path)) {
      await Completer<void>().future;
    }
    if (_firestore.errors[_path] case final error?) {
      throw error;
    }
  }
}

class _RecordingErrorReportingService extends Fake
    implements ErrorReportingService {
  final errors = <Object>[];
  final codes = <Object?>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    errors.add(error);
    codes.add(metadata?['code']);
  }
}
