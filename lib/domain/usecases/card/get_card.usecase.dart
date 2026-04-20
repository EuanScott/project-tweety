import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart';
import 'package:project_tweety/domain/repositories/card/card.repository.dart';

@injectable
class GetCardsUseCase {
  const GetCardsUseCase(this._repository);

  final CardsRepository _repository;

  Future<List<Card>> call() {
    return _repository.getCards();
  }
}

@injectable
class GetCardByIdUseCase {
  const GetCardByIdUseCase(this._repository);

  final CardsRepository _repository;

  Future<Card?> call(String cardId) {
    return _repository.getCardById(cardId);
  }
}