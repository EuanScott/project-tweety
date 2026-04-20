import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

@lazySingleton
class MockCardsDataSource {
  Future<List<CardDto>> getCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<CardDto>.generate(
      10,
      (index) => CardDto(
        title: 'Card Title ${index + 1}',
        description: 'This is the body copy for card number ${index + 1}. '
            'You can replace this with whatever description you want.',
      ),
      growable: false,
    );
  }
}
