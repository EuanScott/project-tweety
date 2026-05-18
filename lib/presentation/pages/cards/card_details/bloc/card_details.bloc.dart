import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart';
import 'package:project_tweety/domain/usecases/card/get_card.usecase.dart';

part 'card_details.event.dart';
part 'card_details.state.dart';
part 'card_details.bloc.freezed.dart';

@injectable
class CardDetailsBloc extends Bloc<CardDetailsEvent, CardDetailsState> {
  CardDetailsBloc(this._getCardByIdUseCase) : super(const CardDetailsState()) {
    on<CardDetailsStarted>(_onStarted);
  }

  final GetCardByIdUseCase _getCardByIdUseCase;

  Future<void> _onStarted(
    CardDetailsStarted event,
    Emitter<CardDetailsState> emit,
  ) async {
    emit(
      state.copyWith(
        cardId: event.cardId,
        status: CardDetailsStatus.loading,
        card: null,
        errorMessage: null,
      ),
    );

    try {
      final card = await _getCardByIdUseCase(event.cardId);

      if (card == null) {
        emit(
          state.copyWith(
            cardId: event.cardId,
            status: CardDetailsStatus.missing,
            card: null,
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          cardId: event.cardId,
          status: CardDetailsStatus.success,
          card: card,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          cardId: event.cardId,
          status: CardDetailsStatus.failure,
          card: null,
          errorMessage: 'Unable to load this card right now.',
        ),
      );
    }
  }
}
