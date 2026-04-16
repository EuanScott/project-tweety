import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/dtos/card_item_dto.dart';

@lazySingleton
class MockCardsDataSource {
  Future<List<CardItemDto>> getCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<CardItemDto>.generate(
      10,
      (index) => CardItemDto(
        title: 'Card Title ${index + 1}',
        description: 'This is the body copy for card number ${index + 1}. '
            'You can replace this with whatever description you want.',
      ),
      growable: false,
    );
  }
}
