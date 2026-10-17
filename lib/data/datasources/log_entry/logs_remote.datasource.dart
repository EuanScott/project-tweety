import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

/// How one log entry's push ended.
enum LogEntryPushOutcome {
  /// The server confirmed the write.
  confirmed,

  /// The server could not be reached in time. Retrying later may succeed.
  networkFailure,

  /// The server refused the write, or it failed for another reason.
  failure,
}

/// The Account's copy of its log entries, written by a sync and never read as
/// truth ([ADR-0007](../../../../docs/decisions/0007-cards-local-source-of-truth.md)).
/// A download reads it only to add log entries the device does not hold
/// ([ADR-0008](../../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)).
abstract class LogsRemoteDataSource {
  /// Reads every log entry of the signed-in Account from the server. Each one
  /// is `synced` and owned by that Account. Throws
  /// `LogsAccountUnreachableException` when the server cannot be reached in
  /// time.
  Future<List<LogEntryDto>> fetchLogs();

  /// Pushes each log entry on its own: a tombstone deletes its copy, and every
  /// other log entry replaces it. Calls [onPushed] as each write settles, and
  /// returns every outcome by log entry id.
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  });
}
