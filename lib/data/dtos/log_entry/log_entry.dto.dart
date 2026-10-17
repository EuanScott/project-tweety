import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';

enum LogEntrySyncStatus {
  synced,
  created,
  updated,
  deleted;

  String get storageValue => name;

  static LogEntrySyncStatus fromStorageValue(Object? value) {
    return switch (value) {
      'synced' => LogEntrySyncStatus.synced,
      'created' => LogEntrySyncStatus.created,
      'updated' => LogEntrySyncStatus.updated,
      'deleted' => LogEntrySyncStatus.deleted,
      _ => LogEntrySyncStatus.synced,
    };
  }
}

class const LogEntryDto({
  required final String id,
  required final String title,
  required final String description,
  final LogEntrySyncStatus syncStatus = LogEntrySyncStatus.synced,
  final DateTime? createdAt,
  final DateTime? updatedAt,
  final DateTime? lastSyncedAt,
  final DateTime? deletedAt,
  final String? userId,
}) {
  Map<String, Object?> toDatabaseRow() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'description': description,
      'sync_status': syncStatus.storageValue,
      'updated_at': updatedAt?.toIso8601String() ?? '',
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt?.toIso8601String() ?? '',
    };
  }

  factory fromDatabaseRow(Map<String, Object?> row) {
    return LogEntryDto(
      id: row['id']! as String,
      title: row['title']! as String,
      description: row['description']! as String,
      syncStatus: LogEntrySyncStatus.fromStorageValue(row['sync_status']),
      createdAt: _dateTimeFromStorageValue(row['created_at']),
      updatedAt: _dateTimeFromStorageValue(row['updated_at']),
      lastSyncedAt: _dateTimeFromStorageValue(row['last_synced_at']),
      deletedAt: _dateTimeFromStorageValue(row['deleted_at']),
      userId: row['user_id'] as String?,
    );
  }

  LogEntry toValue() {
    return LogEntry(id: id, title: title, description: description);
  }

  static DateTime? _dateTimeFromStorageValue(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.parse(value);
  }
}
