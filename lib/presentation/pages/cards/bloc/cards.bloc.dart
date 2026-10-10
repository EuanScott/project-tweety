import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    on<CardsSyncChanged>(_onSyncChanged);
    on<CardsSyncRequested>(_onSyncRequested, transformer: droppable());
  }

  final CardsRepository _cardsRepository;

  void _onSyncChanged(CardsSyncChanged event, Emitter<CardsState> emit) {
    emit(
      state.copyWith(sync: event.sync, unsyncedChanges: event.unsyncedChanges),
    );
  }

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
      await _refreshSync(emit);
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

    final initialDraft = state.initialDraft;
    if (initialDraft != null && state.draft == initialDraft) {
      emit(
        state.copyWith(
          editingCardId: null,
          initialDraft: null,
          invalidDraftFields: const <CardDraftField>{},
          hasSubmittedEdit: false,
          editStatus: CardsEditStatus.idle,
          editError: false,
          missingEditCardId: null,
          updatedCardId: null,
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
      await _refreshSync(emit);
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
      await _refreshSync(emit);
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
      await _refreshSync(emit);
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

  Future<void> _onSyncRequested(
    CardsSyncRequested event,
    Emitter<CardsState> emit,
  ) async {
    if (state.sync.isBusy) {
      return;
    }

    var changeCount = 0;
    try {
      final result = await _cardsRepository.syncCards(
        onProgress: (savedCount, total) {
          changeCount = total;
          emit(
            state.copyWith(
              sync: CardsSync.syncing(
                savedCount: savedCount,
                changeCount: total,
              ),
            ),
          );
        },
      );
      final summary = await _cardsRepository.getSyncSummary();
      final stillPending = summary.pendingChanges.length;
      final outcome = _syncOutcome(result);
      emit(
        state.copyWith(
          // Changes saved during the sync are still pending, so a full
          // success would overstate what reached the Account.
          sync: stillPending > 0 && outcome is CardsSyncSynced
              ? CardsSync.pending(changeCount: stillPending)
              : outcome,
          unsyncedChanges: _unsyncedChanges(summary),
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(sync: CardsSync.failed(changeCount: changeCount)));
    }
  }

  /// Re-reads what is pending after a change is saved. A running sync keeps
  /// its progress; any other state becomes the pending count or the last
  /// sync time.
  Future<void> _refreshSync(Emitter<CardsState> emit) async {
    final CardsSyncSummary summary;
    try {
      summary = await _cardsRepository.getSyncSummary();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      return;
    }

    final changeCount = summary.pendingChanges.length;
    emit(
      state.copyWith(
        unsyncedChanges: _unsyncedChanges(summary),
        sync: state.sync.isBusy
            ? state.sync
            : changeCount == 0
            ? CardsSync.upToDate(lastSyncedAt: summary.lastSyncedAt)
            : CardsSync.pending(changeCount: changeCount),
      ),
    );
  }

  static CardsSync _syncOutcome(CardsSyncResult result) {
    final CardsSyncResult(:changeCount, :savedCount) = result;

    if (changeCount == 0) {
      return const CardsSync.alreadyUpToDate();
    }
    if (savedCount == changeCount) {
      return CardsSync.synced(changeCount: changeCount);
    }
    if (savedCount > 0) {
      return CardsSync.partial(
        savedCount: savedCount,
        changeCount: changeCount,
      );
    }

    return result.onlyNetworkFailures
        ? CardsSync.offline(changeCount: changeCount)
        : CardsSync.failed(changeCount: changeCount);
  }

  /// A deleted Card has no row to mark, so only created and edited Cards
  /// carry a marker.
  static Map<String, UnsyncedCardChange> _unsyncedChanges(
    CardsSyncSummary summary,
  ) => {
    for (final MapEntry(key: cardId, value: change)
        in summary.pendingChanges.entries)
      if (change == PendingCardChange.created)
        cardId: UnsyncedCardChange.created
      else if (change == PendingCardChange.updated)
        cardId: UnsyncedCardChange.updated,
  };
}
