import 'package:project_tweety/domain/entities/card_item.dart';

class CardItemDto {
  const CardItemDto({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  CardItem toEntity() {
    return CardItem(
      title: title,
      description: description,
    );
  }
}
