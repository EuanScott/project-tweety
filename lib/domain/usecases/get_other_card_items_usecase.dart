import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/other_card_item.dart';
import 'package:project_tweety/domain/repositories/other_repository.dart';

@injectable
class GetOtherCardItemsUseCase {
  const GetOtherCardItemsUseCase(this._repository);

  final OtherRepository _repository;

  Future<List<OtherCardItem>> call() {
    return _repository.getOtherCardItems();
  }
}
