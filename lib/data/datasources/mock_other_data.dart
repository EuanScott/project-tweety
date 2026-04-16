import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/dtos/other_card_item_dto.dart';

@lazySingleton
class MockOtherData {
  Future<List<OtherCardItemDto>> getOtherCardItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<OtherCardItemDto>.generate(
      10,
      (index) => OtherCardItemDto(
        title: 'Card Title ${index + 1}',
        description: 'This is the body copy for card number ${index + 1}. '
            'You can replace this with whatever description you want.',
      ),
      growable: false,
    );
  }
}
