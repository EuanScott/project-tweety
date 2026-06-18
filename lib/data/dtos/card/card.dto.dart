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

  Card toValue() {
    return Card(id: id, title: title, description: description);
  }
}
