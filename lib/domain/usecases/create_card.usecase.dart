import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/card.entity.dart';
import 'package:project_tweety/domain/repositories/card.repository.dart';

@injectable
class CreateCardUseCase {
  const CreateCardUseCase(this._repository);

  final CardsRepository _repository;

  Future<Card> call(Card card) {
    return _repository.createCard(card);
  }
}
