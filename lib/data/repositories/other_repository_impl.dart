import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/mock_other_data.dart';
import 'package:project_tweety/domain/entities/other_card_item.dart';
import 'package:project_tweety/domain/repositories/other_repository.dart';

@LazySingleton(as: OtherRepository)
class OtherRepositoryImpl implements OtherRepository {
  const OtherRepositoryImpl(this._mockOtherData);

  final MockOtherData _mockOtherData;

  @override
  Future<List<OtherCardItem>> getOtherCardItems() async {
    final items = await _mockOtherData.getOtherCardItems();
    return items.map((item) => item.toEntity()).toList(growable: false);
  }
}
