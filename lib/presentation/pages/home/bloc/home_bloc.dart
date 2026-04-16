import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting_facade.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

enum HomeAction { cancel, next, primary, secondary, back }

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.errorReporting) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeActionPressed>(_onActionPressed);
  }

  final ErrorReportingFacade errorReporting;

  void _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        status: HomeStatus.ready,
      ),
    );
  }

  Future<void> _onActionPressed(
    HomeActionPressed event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          lastAction: event.action,
        ),
      );
    } catch (error, stacktrace) {
      unawaited(errorReporting.recordError(error, stacktrace));
      rethrow;
    }
  }
}
