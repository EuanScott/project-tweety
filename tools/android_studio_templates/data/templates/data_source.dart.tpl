import 'package:injectable/injectable.dart';
import 'package:__PACKAGE_NAME__/data/dtos/__ENTITY_NAME___dto.dart';

@lazySingleton
class Mock__FEATURE_PASCAL__DataSource {
  Future<List<__ENTITY_PASCAL__Dto>> get__FEATURE_PASCAL__() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return List<__ENTITY_PASCAL__Dto>.generate(
      10,
      (index) => __ENTITY_PASCAL__Dto(
        title: '__ENTITY_PASCAL__ ${index + 1}',
        description: 'Replace this placeholder copy with real __FEATURE_NAME__ data.',
      ),
      growable: false,
    );
  }
}
