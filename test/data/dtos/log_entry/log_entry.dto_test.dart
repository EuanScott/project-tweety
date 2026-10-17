import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';

void main() {
  group('LogEntrySyncStatus.fromStorageValue', () {
    test('reads every stored name back', () {
      for (final status in LogEntrySyncStatus.values) {
        expect(
          LogEntrySyncStatus.fromStorageValue(status.storageValue),
          status,
        );
      }
    });

    test('reads an unknown value as updated so it is pushed again', () {
      expect(
        LogEntrySyncStatus.fromStorageValue('garbage'),
        LogEntrySyncStatus.updated,
      );
      expect(
        LogEntrySyncStatus.fromStorageValue(null),
        LogEntrySyncStatus.updated,
      );
    });
  });

  group('LogEntryDto.fromDatabaseRow', () {
    Map<String, Object?> row({Object? status, String? deletedAt}) => {
      'id': 'a',
      'title': 't',
      'description': 'd',
      'sync_status': status,
      'created_at': '2026-01-01T00:00:00.000',
      'updated_at': '2026-01-01T00:00:00.000',
      'last_synced_at': null,
      'deleted_at': deletedAt,
      'user_id': 'u',
    };

    test('an unknown status on a live row becomes updated', () {
      final dto = LogEntryDto.fromDatabaseRow(row(status: 'garbage'));

      expect(dto.syncStatus, LogEntrySyncStatus.updated);
    });

    test('an unknown status on a row with deleted_at stays deleted', () {
      final dto = LogEntryDto.fromDatabaseRow(
        row(status: 'garbage', deletedAt: '2026-02-01T00:00:00.000'),
      );

      expect(dto.syncStatus, LogEntrySyncStatus.deleted);
    });
  });
}
