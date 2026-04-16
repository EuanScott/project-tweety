import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/entities/other_card_item.dart';
import 'package:project_tweety/domain/usecases/get_other_card_items_usecase.dart';

part 'other_event.dart';
part 'other_state.dart';
part 'other_bloc.freezed.dart';

@injectable
class OtherBloc extends Bloc<OtherEvent, OtherState> {
  OtherBloc(this._getOtherCardItemsUseCase) : super(const OtherState()) {
    on<OtherStarted>(_onStarted);
  }

  final GetOtherCardItemsUseCase _getOtherCardItemsUseCase;

  Future<void> _onStarted(
    OtherStarted event,
    Emitter<OtherState> emit,
  ) async {
    emit(
      state.copyWith(
        status: OtherStatus.loading,
        items: const [],
        errorMessage: null,
      ),
    );

    try {
      final items = await _getOtherCardItemsUseCase();

      emit(
        state.copyWith(
          status: OtherStatus.success,
          items: items,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: OtherStatus.failure,
          items: const [],
          errorMessage: 'Unable to load cards right now.',
        ),
      );
    }
  }
}
