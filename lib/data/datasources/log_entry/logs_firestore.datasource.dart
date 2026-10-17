import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

/// Log entries in Firestore at `users/{uid}/cards/{cardId}`.
///
/// Offline persistence is off, so a write waits for the server. Each write
/// has its own timeout, so an offline push ends instead of waiting forever.
@LazySingleton(as: LogsRemoteDataSource)
class const FirestoreLogsRemoteDataSource(
  final FirebaseFirestore _firestore,
  final SessionHolder _sessionHolder,
  final ErrorReportingFacade _errorReporting,
) implements LogsRemoteDataSource {
  /// The stored name predates the Logs rename and is kept
  /// ([ADR-0019](../../../../docs/decisions/0019-log-entries-keep-the-cards-storage-names.md)).
  static const _collection = 'cards';
  static const _writeTimeout = Duration(seconds: 10);
  static const _unavailableCode = 'unavailable';

  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) async {
    final uid = _sessionHolder.uid;
    final outcomes = await Future.wait(
      logs.map((logEntry) async {
        final outcome = await _push(uid, logEntry);
        onPushed?.call(logEntry.id, outcome);

        return MapEntry(logEntry.id, outcome);
      }),
    );

    return Map.fromEntries(outcomes);
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
