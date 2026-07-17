import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/_template/_template.repository.dart';

part '_template.event.dart';
part '_template.state.dart';
part '_template.bloc.freezed.dart';

@injectable
class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc(this._repository) : super(const TemplateState()) {
    on<TemplateStarted>(_onStarted);
  }

  final TemplateRepository _repository;

  Future<void> _onStarted(
    TemplateStarted event,
    Emitter<TemplateState> emit,
  ) async {
    emit(state.copyWith(status: TemplateStatus.loading, errorMessage: null));

    try {
      await _repository.fetchTemplate();

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
