import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

/// A server for local development that confirms every push and holds
/// nothing, so a Sync succeeds and a Download adds nothing.
///
/// The dev Account is not a real Firebase user, so Firestore would refuse it.
class const DevLogsRemoteDataSource() implements LogsRemoteDataSource {
  @override
  Future<List<LogEntryDto>> fetchLogs() async => const [];

  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) async {
    final outcomes = <String, LogEntryPushOutcome>{
      for (final logEntry in logs) logEntry.id: .confirmed,
    }..forEach((id, outcome) => onPushed?.call(id, outcome));

    return outcomes;
  }
}
