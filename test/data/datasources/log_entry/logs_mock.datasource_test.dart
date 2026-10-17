import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_mock.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

void main() {
  test('follows the datasource unsynced log entries contract', () async {
    final LogsDataSource dataSource = MockLogsDataSource();
    final createdLogEntry = await dataSource.createLogEntry(
      const LogEntryDto(
        id: 'card-11',
        title: 'New entry',
        description: 'New card description',
      ),
    );

    expect(createdLogEntry.syncStatus, LogEntrySyncStatus.created);
    expect(createdLogEntry.updatedAt?.isUtc, isTrue);

    final unsyncedLogs = await dataSource.getUnsyncedLogs();
    expect(unsyncedLogs.single.id, 'card-11');
    expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.created);

    await dataSource.markLogsSynced(await dataSource.getUnsyncedLogs());

    expect(await dataSource.getUnsyncedLogs(), isEmpty);
    final syncedLogEntry = await dataSource.getLogEntryById('card-11');
    expect(syncedLogEntry?.syncStatus, LogEntrySyncStatus.synced);
    expect(syncedLogEntry?.lastSyncedAt?.isUtc, isTrue);
  });

  test('hides deleted tombstones from normal reads', () async {
    final LogsDataSource dataSource = MockLogsDataSource();

    await dataSource.deleteLogEntry('card-1');

    expect(
      (await dataSource.getLogs()).map((logEntry) => logEntry.id),
      isNot(contains('card-1')),
    );
    expect(await dataSource.getLogEntryById('card-1'), isNull);
    final unsyncedLogs = await dataSource.getUnsyncedLogs();
    expect(unsyncedLogs.single.id, 'card-1');
    expect(unsyncedLogs.single.syncStatus, LogEntrySyncStatus.deleted);
  });

  test(
    'lists a created log entry first and keeps its creation time on edit',
    () async {
      final LogsDataSource dataSource = MockLogsDataSource();
      final createdLogEntry = await dataSource.createLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'New entry',
          description: 'Body',
        ),
      );

      final updatedLogEntry = await dataSource.updateLogEntry(
        const LogEntryDto(
          id: 'card-11',
          title: 'Edited card',
          description: 'Body',
        ),
      );

      expect((await dataSource.getLogs()).first.id, 'card-11');
      expect(createdLogEntry.createdAt?.isUtc, isTrue);
      expect(updatedLogEntry?.createdAt, createdLogEntry.createdAt);
    },
  );
}
