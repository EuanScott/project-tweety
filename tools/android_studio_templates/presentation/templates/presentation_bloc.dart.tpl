import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:__PACKAGE_NAME__/domain/entities/__ENTITY_NAME__.dart';
import 'package:__PACKAGE_NAME__/domain/usecases/get___FEATURE_NAME___usecase.dart';

part '__FEATURE_NAME___bloc.freezed.dart';
part '__FEATURE_NAME___event.dart';
part '__FEATURE_NAME___state.dart';

@injectable
class __FEATURE_PASCAL__Bloc
    extends Bloc<__FEATURE_PASCAL__Event, __FEATURE_PASCAL__State> {
  __FEATURE_PASCAL__Bloc(this._get__FEATURE_PASCAL__UseCase)
      : super(const __FEATURE_PASCAL__State()) {
    on<__FEATURE_PASCAL__Started>(_onStarted);
  }

  final Get__FEATURE_PASCAL__UseCase _get__FEATURE_PASCAL__UseCase;

  Future<void> _onStarted(
    __FEATURE_PASCAL__Started event,
    Emitter<__FEATURE_PASCAL__State> emit,
  ) async {
    emit(
      state.copyWith(
        status: __FEATURE_PASCAL__Status.loading,
        items: const [],
        errorMessage: null,
      ),
    );

    try {
      final items = await _get__FEATURE_PASCAL__UseCase();

      emit(
        state.copyWith(
          status: __FEATURE_PASCAL__Status.success,
          items: items,
          errorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: __FEATURE_PASCAL__Status.failure,
          items: const [],
          errorMessage: 'Unable to load __FEATURE_NAME__ right now.',
        ),
      );
    }
  }
}
