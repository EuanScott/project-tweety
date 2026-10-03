import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

part 'sign_in.state.dart';
part 'sign_in.cubit.freezed.dart';

/// Runs one sign-in attempt at a time.
///
/// It never navigates. A successful attempt changes the Session, and the
/// launch gate moves the person into the app.
@injectable
class SignInCubit extends Cubit<SignInAttemptState> {
  new(this._repository) : super(const SignInAttemptState.idle());

  final AuthRepository _repository;

  Future<void> signInRequested() async {
    if (state is SignInAttemptInProgress) {
      return;
    }

    emit(const SignInAttemptState.inProgress());

    final SignInResult result;
    try {
      result = await _repository.signInWithGoogle();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const SignInAttemptState.failed(SignInFailure.other));
      return;
    }

    switch (result) {
      case SignInSucceeded():
        // Stay in progress: the gate disposes this page, so the button never
        // flashes back to enabled.
        return;
      case SignInCancelled():
        emit(const SignInAttemptState.idle());
      case SignInFailed(:final failure):
        emit(SignInAttemptState.failed(failure));
    }
  }
}
