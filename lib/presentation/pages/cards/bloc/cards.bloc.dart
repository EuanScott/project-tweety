import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';

part 'cards.event.dart';
part 'cards.state.dart';
part 'cards.bloc.freezed.dart';

@injectable
class CardsBloc extends Bloc<CardsEvent, CardsState> {
  CardsBloc(this._cardsRepository) : super(const CardsState()) {
    on<CardsStarted>(_onStarted);
  }

  final CardsRepository _cardsRepository;

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
}
