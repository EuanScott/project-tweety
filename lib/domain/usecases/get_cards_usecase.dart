import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/card_item.dart';
import 'package:project_tweety/domain/repositories/cards_repository.dart';

@injectable
class GetCardsUseCase {
  const GetCardsUseCase(this._repository);

  final CardsRepository _repository;

  Future<List<CardItem>> call() {
    return _repository.getCards();
  }
}
