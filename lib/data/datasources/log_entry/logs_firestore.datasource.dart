import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

/// Log entries in Firestore at `users/{uid}/cards/{cardId}`.
///
/// Offline persistence is off, so a write waits for the server. Each write
/// has its own timeout, so an offline push ends instead of waiting forever.
/// Only [maxConcurrentWrites] writes run at once, so a write waiting in the
/// client queue never spends its timeout before it starts.
@LazySingleton(as: LogsRemoteDataSource)
class const FirestoreLogsRemoteDataSource(
  final FirebaseFirestore _firestore,
  final SessionHolder _sessionHolder,
  final ErrorReportingFacade _errorReporting,
) implements LogsRemoteDataSource {
  /// The stored name predates the Logs rename and is kept
  /// ([ADR-0019](../../../../docs/decisions/0019-log-entries-keep-the-cards-storage-names.md)).
  static const _collection = 'cards';
  static const maxConcurrentWrites = 10;
  static const _writeTimeout = Duration(seconds: 10);

  /// One read returns every document, so it gets longer than one write.
  static const _readTimeout = Duration(seconds: 30);
  static const _unavailableCode = 'unavailable';

  @override
  Future<List<LogEntryDto>> fetchLogs() async {
    final uid = _sessionHolder.uid;
    final QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _firestore
          .collection('users/$uid/$_collection')
          .get(const GetOptions(source: Source.server))
          .timeout(_readTimeout);
    } on TimeoutException {
      throw const LogsAccountUnreachableException();
    } on FirebaseException catch (error) {
      if (error.code == _unavailableCode) {
        throw const LogsAccountUnreachableException();
      }
      rethrow;
    }

    final logs = <LogEntryDto>[];
    for (final document in snapshot.docs) {
      try {
        logs.add(_fromDocument(uid, document.id, document.data()));
      } on FormatException catch (error, stackTrace) {
        // One damaged document must not block the download of the rest.
        unawaited(_errorReporting.recordError(error, stackTrace));
      }
    }

    return logs;
  }

  static LogEntryDto _fromDocument(
    String uid,
    String id,
    Map<String, dynamic> data,
  ) {
    if (data case {
      'title': final String title,
      'description': final String description,
      'updatedAt': final Timestamp updatedAt,
    }) {
      final createdAt = data['createdAt'];

      return LogEntryDto(
        id: id,
        title: title,
        description: description,
        createdAt: (createdAt is Timestamp ? createdAt : updatedAt)
            .toDate()
            .toUtc(),
        updatedAt: updatedAt.toDate().toUtc(),
        userId: uid,
      );
    }

    throw FormatException('Log entry document $id is missing a field');
  }

  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) async {
    final uid = _sessionHolder.uid;
    final outcomes = <String, LogEntryPushOutcome>{};
    var next = 0;
    // A worker takes the next log entry as soon as its own write settles, so
    // one slow write holds up a single slot, not a whole batch.
    Future<void> work() async {
      while (next < logs.length) {
        final logEntry = logs[next++];
        final outcome = await _push(uid, logEntry);
        outcomes[logEntry.id] = outcome;
        onPushed?.call(logEntry.id, outcome);
      }
    }

    await Future.wait([
      for (var i = 0; i < min(maxConcurrentWrites, logs.length); i++) work(),
    ]);

    return outcomes;
  }

  Future<LogEntryPushOutcome> _push(String uid, LogEntryDto logEntry) async {
    final document = _firestore.doc('users/$uid/$_collection/${logEntry.id}');
    final updatedAt = logEntry.updatedAt ?? DateTime.now().toUtc();
    try {
      final write = logEntry.syncStatus == LogEntrySyncStatus.deleted
          ? document.delete()
          : document.set(<String, Object?>{
              'title': logEntry.title,
              'description': logEntry.description,
              // A log entry stored before creation times existed is dated from
              // its last change, matching how the local store backfilled it.
              'createdAt': Timestamp.fromDate(logEntry.createdAt ?? updatedAt),
              'updatedAt': Timestamp.fromDate(updatedAt),
            });
      await write.timeout(_writeTimeout);

      return LogEntryPushOutcome.confirmed;
    } on TimeoutException {
      return LogEntryPushOutcome.networkFailure;
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == _unavailableCode) {
        return LogEntryPushOutcome.networkFailure;
      }

      unawaited(
        _errorReporting.recordError(
          error,
          stackTrace,
          metadata: {'code': error.code},
        ),
      );

      return LogEntryPushOutcome.failure;
    }
  }
}
