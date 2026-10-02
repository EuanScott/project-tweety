import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';

part 'home.event.dart';
part 'home.state.dart';
part 'home.bloc.freezed.dart';

enum HomeAction { cancel, next, primary, secondary, back }

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  new(this._errorReporting) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeActionPressed>(_onActionPressed);
  }

  final ErrorReportingFacade _errorReporting;

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.ready));
  }

  Future<void> _onActionPressed(
    HomeActionPressed event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HomeStatus.ready, lastAction: event.action));
    } catch (error, stacktrace) {
      unawaited(_errorReporting.recordError(error, stacktrace));
      rethrow;
    }
  }
}
