import 'package:__PACKAGE_NAME__/domain/entities/__ENTITY_NAME__.dart';

class __ENTITY_PASCAL__Dto {
  const __ENTITY_PASCAL__Dto({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  __ENTITY_PASCAL__ toEntity() {
    return __ENTITY_PASCAL__(
      title: title,
      description: description,
    );
  }
}
