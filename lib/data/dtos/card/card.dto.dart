import 'package:project_tweety/data/repositories/card/cards.repository.dart';

class CardDto {
  const CardDto({
    required this.id,
    required this.title,
    required this.description,
    this.syncStatus = CardSyncStatus.synced,
    this.updatedAt,
    this.lastSyncedAt,
    this.deletedAt,
  });

  final String id;
  final String title;
  final String description;
  final CardSyncStatus syncStatus;
  final DateTime? updatedAt;
  final DateTime? lastSyncedAt;
  final DateTime? deletedAt;

  Map<String, Object?> toDatabaseRow() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'description': description,
      'sync_status': syncStatus.storageValue,
      'updated_at': updatedAt?.toIso8601String() ?? '',
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory CardDto.fromDatabaseRow(Map<String, Object?> row) {
    return CardDto(
      id: row['id']! as String,
      title: row['title']! as String,
      description: row['description']! as String,
      syncStatus: CardSyncStatus.fromStorageValue(row['sync_status']),
      updatedAt: _dateTimeFromStorageValue(row['updated_at']),
      lastSyncedAt: _dateTimeFromStorageValue(row['last_synced_at']),
      deletedAt: _dateTimeFromStorageValue(row['deleted_at']),
    );
  }

  Card toValue() {
    return Card(id: id, title: title, description: description);
  }

  static DateTime? _dateTimeFromStorageValue(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.parse(value);
  }
}
