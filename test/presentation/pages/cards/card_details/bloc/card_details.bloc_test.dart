import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/presentation/pages/cards/card_details/bloc/card_details.bloc.dart';

void main() {
  const card = Card(
    id: 'card-1',
    title: 'Card Title 1',
    description: 'Card body',
  );

  CardDetailsBloc buildBloc(CardsRepository repository) {
    return CardDetailsBloc(repository);
  }

  group('CardDetailsBloc', () {
    blocTest<CardDetailsBloc, CardDetailsState>(
      'emits success when the card is found',
      build: () => buildBloc(const _FakeCardsRepository(card: card)),
      act: (bloc) => bloc.add(const CardDetailsStarted('card-1')),
      expect: () => [
        const CardDetailsState(
          cardId: 'card-1',
          status: CardDetailsStatus.loading,
        ),
        const CardDetailsState(
          cardId: 'card-1',
          status: CardDetailsStatus.success,
          card: card,
        ),
      ],
    );

    blocTest<CardDetailsBloc, CardDetailsState>(
      'emits missing when the card is not found',
      build: () => buildBloc(const _FakeCardsRepository()),
      act: (bloc) => bloc.add(const CardDetailsStarted('missing-card')),
      expect: () => [
        const CardDetailsState(
          cardId: 'missing-card',
          status: CardDetailsStatus.loading,
        ),
        const CardDetailsState(
          cardId: 'missing-card',
          status: CardDetailsStatus.missing,
        ),
      ],
    );

    blocTest<CardDetailsBloc, CardDetailsState>(
      'emits failure when loading throws',
      build: () =>
          buildBloc(_FakeCardsRepository(error: StateError('load failed'))),
      act: (bloc) => bloc.add(const CardDetailsStarted('card-1')),
      expect: () => [
        const CardDetailsState(
          cardId: 'card-1',
          status: CardDetailsStatus.loading,
        ),
        const CardDetailsState(
          cardId: 'card-1',
          status: CardDetailsStatus.failure,
          errorMessage: 'Unable to load this card right now.',
        ),
      ],
      errors: () => [isA<StateError>()],
    );
  });
}

class _FakeCardsRepository implements CardsRepository {
  const _FakeCardsRepository({this.card, this.error});

  final Card? card;
  final Object? error;

  @override
  Future<List<Card>> getCards() async {
    return card == null ? const [] : [card!];
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return card?.id == cardId ? card : null;
  }

  @override
  Future<void> createCard(Card card) async {}

  @override
  Future<void> updateCard(Card card) async {}

  @override
  Future<void> deleteCard(String cardId) async {}
}
