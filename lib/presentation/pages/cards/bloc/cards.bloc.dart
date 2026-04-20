import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart';
import 'package:project_tweety/domain/usecases/card/get_card.usecase.dart';

part 'cards.event.dart';
part 'cards.state.dart';
part 'cards.bloc.freezed.dart';

@injectable
class CardsBloc extends Bloc<CardsEvent, CardsState> {
  CardsBloc(this._getCardsUseCase) : super(const CardsState()) {
    on<CardsStarted>(_onStarted);
  }

  final GetCardsUseCase _getCardsUseCase;

  Future<void> _onStarted(
    CardsStarted event,
    Emitter<CardsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CardsStatus.loading,
        items: const [],
        errorMessage: null,
      ),
    );

    try {
      final items = await _getCardsUseCase();

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
}
