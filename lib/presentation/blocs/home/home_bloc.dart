import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting_facade.dart';

// part 'home_bloc.freezed.dart';
part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(/*this.errorReporting*/) : super(HomeInitial()) {
    on<HomeEvent>(_onHome);

    final ErrorReportingFacade errorReporting;
  }

  Future<void> _onHome(HomeEvent event, Emitter<HomeState> emit) async {
    try {
      // do something here
    } catch (error, stacktrace) {
      // example usage
      // unawaited(errorReporting.recordError(error, stacktrace));

      rethrow;
    }
  }
}
