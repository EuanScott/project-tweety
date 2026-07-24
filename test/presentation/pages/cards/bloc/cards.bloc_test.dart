import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/presentation/pages/cards/bloc/cards.bloc.dart';

void main() {
  const card = Card(
    id: 'card-1',
    title: 'Card Title 1',
    description: 'Card body',
  );

  group('CardsBloc', () {
    blocTest<CardsBloc, CardsState>(
      'tracks dirty state from raw draft values against the editor snapshot',
      build: () => CardsBloc(const _FakeCardsRepository(cards: [card])),
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) => bloc
        ..add(const CardsEditStarted('card-1'))
        ..add(
          const CardsDraftChanged(
            CardDraft(title: ' Card Title 1 ', description: 'Card body'),
          ),
        ),
      expect: () => [
        isA<CardsState>().having(
          (state) => state.isDraftDirty,
          'is dirty',
          isFalse,
        ),
        isA<CardsState>().having(
          (state) => state.isDraftDirty,
          'is dirty',
          isTrue,
        ),
      ],
    );
    late _ControlledCreateCardsRepository controlledCreateRepository;
    blocTest<CardsBloc, CardsState>(
      'loads the collection and derives selected and missing details from it',
      build: () => CardsBloc(const _FakeCardsRepository(cards: [card])),
      act: (bloc) => bloc.add(const CardsStarted()),
      expect: () => [
        const CardsState(status: CardsStatus.loading),
        const CardsState(status: CardsStatus.success, items: [card]),
      ],
      verify: (bloc) {
        expect(bloc.state.detailFor('card-1'), const CardsDetail.success(card));
        expect(
          bloc.state.detailFor('missing-card'),
          const CardsDetail.missing(),
        );
      },
    );

    blocTest<CardsBloc, CardsState>(
      'derives loading and failure details from collection loading',
      build: () => CardsBloc(_FakeCardsRepository(error: StateError('failed'))),
      act: (bloc) => bloc.add(const CardsStarted()),
      expect: () => [
        const CardsState(status: CardsStatus.loading),
        const CardsState(
          status: CardsStatus.failure,
          errorMessage: 'Unable to load cards right now.',
        ),
      ],
      verify: (bloc) {
        expect(
          const CardsState(status: CardsStatus.loading).detailFor('card-1'),
          const CardsDetail.loading(),
        );
        expect(
          bloc.state.detailFor('card-1'),
          const CardsDetail.failure('Unable to load cards right now.'),
        );
      },
      errors: () => [isA<StateError>()],
    );

    blocTest<CardsBloc, CardsState>(
      'shows validation after submit and updates it from raw draft changes',
      build: () => CardsBloc(const _FakeCardsRepository()),
      act: (bloc) => bloc
        ..add(
          const CardsDraftChanged(CardDraft(title: '  ', description: '\t')),
        )
        ..add(const CardsCreateSubmitted())
        ..add(
          const CardsDraftChanged(
            CardDraft(title: 'Raw title', description: '\t'),
          ),
        )
        ..add(
          const CardsDraftChanged(
            CardDraft(title: 'Raw title', description: 'Raw description'),
          ),
        ),
      expect: () => [
        const CardsState(
          draft: CardDraft(title: '  ', description: '\t'),
        ),
        const CardsState(
          draft: CardDraft(title: '  ', description: '\t'),
          hasSubmittedCreate: true,
          invalidDraftFields: {
            CardDraftField.title,
            CardDraftField.description,
          },
        ),
        const CardsState(
          draft: CardDraft(title: 'Raw title', description: '\t'),
          hasSubmittedCreate: true,
          invalidDraftFields: {CardDraftField.description},
        ),
        const CardsState(
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          hasSubmittedCreate: true,
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'ignores duplicate create submissions while one is pending',
      build: () {
        controlledCreateRepository = _ControlledCreateCardsRepository();
        return CardsBloc(controlledCreateRepository);
      },
      act: (bloc) async {
        bloc
          ..add(
            const CardsDraftChanged(
              CardDraft(title: 'New title', description: 'New description'),
            ),
          )
          ..add(const CardsCreateSubmitted())
          ..add(const CardsCreateSubmitted());
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.createRequestCount, 1);
        controlledCreateRepository.completeCreate();
      },
      expect: () => [
        const CardsState(
          draft: CardDraft(title: 'New title', description: 'New description'),
        ),
        const CardsState(
          draft: CardDraft(title: 'New title', description: 'New description'),
          hasSubmittedCreate: true,
          createStatus: CardsCreateStatus.creating,
        ),
        const CardsState(
          draft: CardDraft(title: 'New title', description: 'New description'),
          items: [
            Card(
              id: 'created-card',
              title: 'New title',
              description: 'New description',
            ),
          ],
          hasSubmittedCreate: true,
          createStatus: CardsCreateStatus.success,
          createdCardId: 'created-card',
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'retains the raw draft after a create failure',
      build: () => CardsBloc(_FailingCreateCardsRepository()),
      act: (bloc) => bloc
        ..add(
          const CardsDraftChanged(
            CardDraft(title: '  Raw title  ', description: 'Raw description'),
          ),
        )
        ..add(const CardsCreateSubmitted()),
      expect: () => [
        const CardsState(
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
        ),
        const CardsState(
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          createStatus: CardsCreateStatus.creating,
        ),
        const CardsState(
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          createStatus: CardsCreateStatus.failure,
          createError: true,
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<CardsBloc, CardsState>(
      'preserves the active raw draft and validation state when refreshing',
      build: () => CardsBloc(const _FakeCardsRepository(cards: [card])),
      seed: () => const CardsState(
        draft: CardDraft(
          title: '  Raw title  ',
          description: 'Raw description',
        ),
        hasSubmittedCreate: true,
        invalidDraftFields: {CardDraftField.title},
      ),
      act: (bloc) => bloc.add(const CardsStarted()),
      expect: () => [
        const CardsState(
          status: CardsStatus.loading,
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          invalidDraftFields: {CardDraftField.title},
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          hasSubmittedCreate: true,
          invalidDraftFields: {CardDraftField.title},
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'updates an edited card atomically and returns to read-only details',
      build: () => CardsBloc(const _FakeCardsRepository(cards: [card])),
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) => bloc
        ..add(const CardsEditStarted('card-1'))
        ..add(
          const CardsDraftChanged(
            CardDraft(title: '  Updated title  ', description: 'Updated body'),
          ),
        )
        ..add(const CardsEditSubmitted()),
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Card Title 1', description: 'Card body'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(
            title: '  Updated title  ',
            description: 'Updated body',
          ),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(
            title: '  Updated title  ',
            description: 'Updated body',
          ),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.updating,
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [
            Card(
              id: 'card-1',
              title: 'Updated title',
              description: 'Updated body',
            ),
          ],
          editStatus: CardsEditStatus.success,
          updatedCardId: 'card-1',
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'retains an edit draft but exposes a non-retryable missing target',
      build: () => CardsBloc(_MissingUpdateCardsRepository()),
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) => bloc
        ..add(const CardsEditStarted('card-1'))
        ..add(
          const CardsDraftChanged(
            CardDraft(title: 'Raw title', description: 'Raw description'),
          ),
        )
        ..add(const CardsEditSubmitted()),
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Card Title 1', description: 'Card body'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.updating,
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.notFound,
          missingEditCardId: 'card-1',
        ),
      ],
      errors: () => [isA<CardNotFoundException>()],
    );

    blocTest<CardsBloc, CardsState>(
      'ignores duplicate edit submissions while an update is pending',
      build: () {
        controlledCreateRepository = _ControlledCreateCardsRepository();
        return CardsBloc(controlledCreateRepository);
      },
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) async {
        bloc
          ..add(const CardsEditStarted('card-1'))
          ..add(const CardsEditSubmitted())
          ..add(const CardsEditSubmitted());
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.updateRequestCount, 1);
        controlledCreateRepository.completeUpdate(card);
      },
      skip: 1,
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Card Title 1', description: 'Card body'),
          initialDraft: CardDraft(
            title: 'Card Title 1',
            description: 'Card body',
          ),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.updating,
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          editStatus: CardsEditStatus.success,
          updatedCardId: 'card-1',
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'preserves an active edit draft and validation state when refreshing',
      build: () => CardsBloc(const _FakeCardsRepository(cards: [card])),
      seed: () => const CardsState(
        status: CardsStatus.success,
        items: [card],
        draft: CardDraft(
          title: '  Raw title  ',
          description: 'Raw description',
        ),
        invalidDraftFields: {CardDraftField.title},
        editingCardId: 'card-1',
        hasSubmittedEdit: true,
      ),
      act: (bloc) => bloc.add(const CardsStarted()),
      expect: () => [
        const CardsState(
          status: CardsStatus.loading,
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          invalidDraftFields: {CardDraftField.title},
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(
            title: '  Raw title  ',
            description: 'Raw description',
          ),
          invalidDraftFields: {CardDraftField.title},
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'retains the raw edit draft after a recoverable update failure',
      build: () => CardsBloc(_FailingUpdateCardsRepository()),
      seed: () => const CardsState(
        status: CardsStatus.success,
        items: [card],
        draft: CardDraft(title: 'Raw title', description: 'Raw description'),
        editingCardId: 'card-1',
      ),
      act: (bloc) => bloc.add(const CardsEditSubmitted()),
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.updating,
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          draft: CardDraft(title: 'Raw title', description: 'Raw description'),
          editingCardId: 'card-1',
          hasSubmittedEdit: true,
          editStatus: CardsEditStatus.failure,
          editError: true,
        ),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<CardsBloc, CardsState>(
      'removes a card after deletion and ignores duplicate requests while pending',
      build: () {
        controlledCreateRepository = _ControlledCreateCardsRepository();
        return CardsBloc(controlledCreateRepository);
      },
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) async {
        bloc
          ..add(const CardsDeleteSubmitted('card-1'))
          ..add(const CardsDeleteSubmitted('card-1'));
        await Future<void>.delayed(Duration.zero);
        expect(controlledCreateRepository.deleteRequestCount, 1);
        controlledCreateRepository.completeDelete();
      },
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          deleteStatus: CardsDeleteStatus.deleting,
          deletingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          deletedCardId: 'card-1',
          deleteStatus: CardsDeleteStatus.success,
        ),
      ],
    );

    blocTest<CardsBloc, CardsState>(
      'retains the card and exposes retryable deletion failure',
      build: () => CardsBloc(_FailingDeleteCardsRepository()),
      seed: () => const CardsState(status: CardsStatus.success, items: [card]),
      act: (bloc) => bloc.add(const CardsDeleteSubmitted('card-1')),
      expect: () => [
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          deleteStatus: CardsDeleteStatus.deleting,
          deletingCardId: 'card-1',
        ),
        const CardsState(
          status: CardsStatus.success,
          items: [card],
          deleteStatus: CardsDeleteStatus.failure,
          deleteErrorCardId: 'card-1',
        ),
      ],
      errors: () => [isA<StateError>()],
    );
  });
}

class _FakeCardsRepository implements CardsRepository {
  const _FakeCardsRepository({this.cards = const [], this.error});

  final List<Card> cards;
  final Object? error;

  @override
  Future<List<Card>> getCards() async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return cards;
  }

  @override
  Future<Card?> getCardById(String cardId) {
    throw UnsupportedError('Card detail reads must use the loaded collection.');
  }

  @override
  Future<Card> createCard(CardDraft draft) async {
    return Card(
      id: 'created-card',
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
  }

  @override
  Future<Card> updateCard({
    required String cardId,
    required CardDraft draft,
  }) async {
    return Card(
      id: cardId,
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
  }

  @override
  Future<void> deleteCard(String cardId) async {}
}

class _ControlledCreateCardsRepository implements CardsRepository {
  final Completer<Card> _createCompleter = Completer<Card>();
  final Completer<Card> _updateCompleter = Completer<Card>();
  final Completer<void> _deleteCompleter = Completer<void>();
  var createRequestCount = 0;
  var updateRequestCount = 0;
  var deleteRequestCount = 0;

  @override
  Future<Card> createCard(CardDraft draft) {
    createRequestCount++;
    return _createCompleter.future;
  }

  void completeCreate() {
    _createCompleter.complete(
      const Card(
        id: 'created-card',
        title: 'New title',
        description: 'New description',
      ),
    );
  }

  @override
  Future<void> deleteCard(String cardId) {
    deleteRequestCount++;
    return _deleteCompleter.future;
  }

  void completeDelete() => _deleteCompleter.complete();

  @override
  Future<Card?> getCardById(String cardId) async => null;

  @override
  Future<List<Card>> getCards() async => const [];

  @override
  Future<Card> updateCard({required String cardId, required CardDraft draft}) {
    updateRequestCount++;
    return _updateCompleter.future;
  }

  void completeUpdate(Card card) => _updateCompleter.complete(card);
}

class _FailingCreateCardsRepository implements CardsRepository {
  @override
  Future<Card> createCard(CardDraft draft) {
    throw StateError('create failed');
  }

  @override
  Future<void> deleteCard(String cardId) async {}

  @override
  Future<Card?> getCardById(String cardId) async => null;

  @override
  Future<List<Card>> getCards() async => const [];

  @override
  Future<Card> updateCard({required String cardId, required CardDraft draft}) {
    throw UnsupportedError('Card updates are not configured.');
  }
}

class _FailingDeleteCardsRepository extends _FakeCardsRepository {
  @override
  Future<void> deleteCard(String cardId) {
    throw StateError('delete failed');
  }
}

class _MissingUpdateCardsRepository extends _FakeCardsRepository {
  @override
  Future<Card> updateCard({required String cardId, required CardDraft draft}) {
    throw CardNotFoundException(cardId);
  }
}

class _FailingUpdateCardsRepository extends _FakeCardsRepository {
  @override
  Future<Card> updateCard({required String cardId, required CardDraft draft}) {
    throw StateError('update failed');
  }
}
