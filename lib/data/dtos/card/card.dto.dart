import 'package:project_tweety/domain/entities/card/card.entity.dart';

class CardDto {
  const CardDto({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  Card toEntity() {
    return Card(
      title: title,
      description: description,
    );
  }
}
