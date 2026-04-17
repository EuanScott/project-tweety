import 'package:injectable/injectable.dart';
import 'package:__PACKAGE_NAME__/domain/entities/__ENTITY_NAME__.dart';
import 'package:__PACKAGE_NAME__/domain/repositories/__FEATURE_NAME___repository.dart';

@injectable
class Get__FEATURE_PASCAL__UseCase {
  const Get__FEATURE_PASCAL__UseCase(this._repository);

  final __FEATURE_PASCAL__Repository _repository;

  Future<List<__ENTITY_PASCAL__>> call() {
    return _repository.get__FEATURE_PASCAL__();
  }
}
