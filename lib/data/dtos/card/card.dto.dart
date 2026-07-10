import 'package:project_tweety/data/repositories/card/cards.repository.dart';

class CardDto {
  const CardDto({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  factory CardDto.fromDatabaseRow(Map<String, Object?> row) {
    return CardDto(
      id: row['id']! as String,
      title: row['title']! as String,
      description: row['description']! as String,
    );
  }

  Card toValue() {
    return Card(id: id, title: title, description: description);
  }
}
