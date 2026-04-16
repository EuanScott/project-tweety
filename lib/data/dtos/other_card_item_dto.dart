import 'package:project_tweety/domain/entities/other_card_item.dart';

class OtherCardItemDto {
  const OtherCardItemDto({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  OtherCardItem toEntity() {
    return OtherCardItem(
      title: title,
      description: description,
    );
  }
}
