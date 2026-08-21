import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';

part 'cards.event.dart';
part 'cards.state.dart';
part 'cards.bloc.freezed.dart';

@injectable
class CardsBloc extends Bloc<CardsEvent, CardsState> {
  new(this._cardsRepository) : super(const CardsState()) {
    on<CardsStarted>(_onStarted);
    on<CardsCreateStarted>(_onCreateStarted);
    on<CardsDraftChanged>(_onDraftChanged);
    on<CardsCreateSubmitted>(_onCreateSubmitted);
    on<CardsEditStarted>(_onEditStarted);
    on<CardsEditCancelled>(_onEditCancelled);
    on<CardsDraftDiscarded>(_onDraftDiscarded);
    on<CardsEditSubmitted>(_onEditSubmitted);
    on<CardsDeleteSubmitted>(_onDeleteSubmitted);
  }

  final CardsRepository _cardsRepository;

  void _onCreateStarted(CardsCreateStarted event, Emitter<CardsState> emit) {
    emit(
      state.copyWith(
        draft: const CardDraft(title: '', description: ''),
        initialDraft: const CardDraft(title: '', description: ''),
        invalidDraftFields: const <CardDraftField>{},
        hasSubmittedCreate: false,
        createStatus: CardsCreateStatus.idle,
        createError: false,
        createdCardId: null,
      ),
    );
  }

  Future<void> _onStarted(CardsStarted event, Emitter<CardsState> emit) async {
    emit(
      state.copyWith(
        status: CardsStatus.loading,
        items: const [],
        errorMessage: null,
      ),
    );

    try {
      final items = await _cardsRepository.getCards();

      emit(
        state.copyWith(
          status: CardsStatus.success,
          items: items,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: CardsStatus.failure,
          items: const [],
          errorMessage: 'Unable to load cards right now.',
        ),
      );
    }
  }

  void _onDraftChanged(CardsDraftChanged event, Emitter<CardsState> emit) {
    final hasSubmitted = state.isEditing
        ? state.hasSubmittedEdit
        : state.hasSubmittedCreate;
    emit(
      state.copyWith(
        draft: event.draft,
        invalidDraftFields: hasSubmitted
            ? event.draft.invalidFields
            : const <CardDraftField>{},
      ),
    );
  }

  void _onEditStarted(CardsEditStarted event, Emitter<CardsState> emit) {
    final card = state.items
        .where((item) => item.id == event.cardId)
        .firstOrNull;
    if (card == null || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        draft: CardDraft(title: card.title, description: card.description),
        initialDraft: CardDraft(
          title: card.title,
          description: card.description,
        ),
        invalidDraftFields: const <CardDraftField>{},
        editingCardId: card.id,
        hasSubmittedEdit: false,
        editStatus: CardsEditStatus.idle,
        editError: false,
        missingEditCardId: null,
        updatedCardId: null,
      ),
    );
  }

  void _onEditCancelled(CardsEditCancelled event, Emitter<CardsState> emit) {
    if (!state.isEditing || state.isUpdating) {
      return;
    }

    emit(
      state.copyWith(
        editingCardId: null,
        initialDraft: null,
        hasSubmittedEdit: false,
        editStatus: CardsEditStatus.idle,
        editError: false,
        missingEditCardId: null,
      ),
    );
  }

  void _onDraftDiscarded(CardsDraftDiscarded event, Emitter<CardsState> emit) {
    if (state.isCreating || state.isEditing) {
      emit(
        state.copyWith(
          draft: const CardDraft(title: '', description: ''),
          initialDraft: null,
          invalidDraftFields: const <CardDraftField>{},
          hasSubmittedCreate: false,
          createStatus: CardsCreateStatus.idle,
          createError: false,
          editingCardId: null,
          hasSubmittedEdit: false,
          editStatus: CardsEditStatus.idle,
          editError: false,
          missingEditCardId: null,
        ),
      );
    }
  }

  Future<void> _onEditSubmitted(
    CardsEditSubmitted event,
    Emitter<CardsState> emit,
  ) async {
    final cardId = state.editingCardId;
    if (cardId == null || state.isUpdating || state.hasMissingEditFor(cardId)) {
      return;
    }

    final invalidDraftFields = state.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          hasSubmittedEdit: true,
          invalidDraftFields: invalidDraftFields,
          editStatus: CardsEditStatus.idle,
          editError: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasSubmittedEdit: true,
        invalidDraftFields: const <CardDraftField>{},
        editStatus: CardsEditStatus.updating,
        editError: false,
        missingEditCardId: null,
        updatedCardId: null,
      ),
    );

    try {
      final updatedCard = await _cardsRepository.updateCard(
        cardId: cardId,
        draft: state.draft,
      );
      emit(
        state.copyWith(
          items: state.items
              .map((card) => card.id == cardId ? updatedCard : card)
              .toList(growable: false),
          draft: const CardDraft(title: '', description: ''),
          initialDraft: null,
          invalidDraftFields: const <CardDraftField>{},
          editingCardId: null,
          hasSubmittedEdit: false,
          editStatus: CardsEditStatus.success,
          editError: false,
          updatedCardId: cardId,
        ),
      );
    } on InvalidCardDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          invalidDraftFields: error.invalidFields,
          editStatus: CardsEditStatus.idle,
        ),
      );
    } on CardNotFoundException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          editStatus: CardsEditStatus.notFound,
          editError: false,
          missingEditCardId: error.cardId,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(editStatus: CardsEditStatus.failure, editError: true),
      );
    }
  }

  Future<void> _onCreateSubmitted(
    CardsCreateSubmitted event,
    Emitter<CardsState> emit,
  ) async {
    if (state.isCreating) {
      return;
    }

    final invalidDraftFields = state.draft.invalidFields;
    if (invalidDraftFields.isNotEmpty) {
      emit(
        state.copyWith(
          hasSubmittedCreate: true,
          invalidDraftFields: invalidDraftFields,
          createStatus: CardsCreateStatus.idle,
          createError: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasSubmittedCreate: true,
        invalidDraftFields: const <CardDraftField>{},
        createStatus: CardsCreateStatus.creating,
        createError: false,
        createdCardId: null,
      ),
    );

    try {
      final card = await _cardsRepository.createCard(state.draft);
      emit(
        state.copyWith(
          items: [...state.items, card],
          createStatus: CardsCreateStatus.success,
          createdCardId: card.id,
        ),
      );
    } on InvalidCardDraftException catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          invalidDraftFields: error.invalidFields,
          createStatus: CardsCreateStatus.idle,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          createStatus: CardsCreateStatus.failure,
          createError: true,
        ),
      );
    }
  }

  Future<void> _onDeleteSubmitted(
    CardsDeleteSubmitted event,
    Emitter<CardsState> emit,
  ) async {
    if (state.isDeleting) {
      return;
    }

    emit(
      state.copyWith(
        deleteStatus: CardsDeleteStatus.deleting,
        deletingCardId: event.cardId,
        deleteErrorCardId: null,
        deletedCardId: null,
      ),
    );

    try {
      await _cardsRepository.deleteCard(event.cardId);
      emit(
        state.copyWith(
          items: state.items
              .where((card) => card.id != event.cardId)
              .toList(growable: false),
          deleteStatus: CardsDeleteStatus.success,
          deletingCardId: null,
          deletedCardId: event.cardId,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          deleteStatus: CardsDeleteStatus.failure,
          deletingCardId: null,
          deleteErrorCardId: event.cardId,
        ),
      );
    }
  }
}
