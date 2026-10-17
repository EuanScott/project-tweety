import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.service.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_firestore.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

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

    test('fails when nobody is signed in', () async {
      sessionHolder.signedInUid = null;

      await expectLater(
        buildDataSource().pushLogs([
          _logEntry('card-1', LogEntrySyncStatus.created),
        ]),
        throwsStateError,
      );
      expect(firestore.writes, isEmpty);
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

  @override
  DocumentReference<Map<String, dynamic>> doc(String documentPath) =>
      _FakeDocumentReference(this, documentPath);
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
