import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';

import 'cards.repository.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._dataSource, this._cardIdGenerator);

  final CardsDataSource _dataSource;
  final CardIdGenerator _cardIdGenerator;

  @override
  Future<List<Card>> getCards() async {
    final items = await _dataSource.getCards();
    return items.map((item) => item.toValue()).toList(growable: false);
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    final item = await _dataSource.getCardById(cardId);
    return item?.toValue();
  }

  @override
  Future<Card> createCard(CardDraft draft) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.createCard(
      CardDto(
        id: _cardIdGenerator.generate(),
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    return item.toValue();
  }

  @override
  Future<Card> updateCard({
    required String cardId,
    required CardDraft draft,
  }) async {
    final trimmedDraft = _validatedTrimmedDraft(draft);
    final item = await _dataSource.updateCard(
      CardDto(
        id: cardId,
        title: trimmedDraft.title,
        description: trimmedDraft.description,
      ),
    );
    if (item == null) {
      throw CardNotFoundException(cardId);
    }
    return item.toValue();
  }

  @override
  Future<void> deleteCard(String cardId) {
    return _dataSource.deleteCard(cardId);
  }

  CardDraft _validatedTrimmedDraft(CardDraft draft) {
    final invalidFields = draft.invalidFields;
    if (invalidFields.isNotEmpty) {
      throw InvalidCardDraftException(invalidFields);
    }
    return draft.trimmed();
  }
}
