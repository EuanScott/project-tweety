import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/domain/usecases/_template/fetch_template.usecase.dart';

part '_template.event.dart';
part '_template.state.dart';
part '_template.bloc.freezed.dart';

@injectable
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc(this._fetchTemplateUseCase) : super(const TemplateState()) {
    on<TemplateStarted>(_onStarted);
  }

  final FetchTemplateUseCase _fetchTemplateUseCase;

  Future<void> _onStarted(
    TemplateStarted event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(status: TemplateStatus.loading, errorMessage: null));

    try {
      await _fetchTemplateUseCase();

      emit(state.copyWith(status: TemplateStatus.success, errorMessage: null));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: TemplateStatus.failure,
          errorMessage: 'Unable to load _template right now.',
        ),
      );
    }
  }
}
