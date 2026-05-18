import 'package:project_tweety/domain/entities/card/card.entity.dart';

class CardDto {
  const CardDto({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  Card toEntity() {
    return Card(id: id, title: title, description: description);
  }
}
