import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/other_card_item.dart';
import 'package:project_tweety/domain/repositories/other_repository.dart';

@LazySingleton(as: OtherRepository)
class DummyOtherRepository implements OtherRepository {
  @override
  Future<List<OtherCardItem>> fetchItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<OtherCardItem>.generate(
      10,
      (index) => OtherCardItem(
        title: 'Card Title ${index + 1}',
        description: 'This is the body copy for card number ${index + 1}. '
            'You can replace this with whatever description you want.',
      ),
      growable: false,
    );
  }
}
