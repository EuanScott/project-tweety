import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/repositories/card/card.repository.dart';

@injectable
class DeleteCardUseCase {
  const DeleteCardUseCase(this._repository);

  final CardsRepository _repository;

  Future<void> call(String cardId) {
    return _repository.deleteCard(cardId);
  }
}
