import 'package:injectable/injectable.dart';
import 'package:__PACKAGE_NAME__/data/datasources/mock___FEATURE_NAME___data_source.dart';
import 'package:__PACKAGE_NAME__/domain/entities/__ENTITY_NAME__.dart';
import 'package:__PACKAGE_NAME__/domain/repositories/__FEATURE_NAME___repository.dart';

@LazySingleton(as: __FEATURE_PASCAL__Repository)
class __FEATURE_PASCAL__RepositoryImpl implements __FEATURE_PASCAL__Repository {
  const __FEATURE_PASCAL__RepositoryImpl(this._mock__FEATURE_PASCAL__DataSource);

  final Mock__FEATURE_PASCAL__DataSource _mock__FEATURE_PASCAL__DataSource;

  @override
  Future<List<__ENTITY_PASCAL__>> get__FEATURE_PASCAL__() async {
    final items = await _mock__FEATURE_PASCAL__DataSource.get__FEATURE_PASCAL__();
    return items.map((item) => item.toEntity()).toList(growable: false);
  }
}
