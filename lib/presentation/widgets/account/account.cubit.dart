import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';

part 'account.state.dart';
part 'account.cubit.freezed.dart';

/// The signed-in person's Profile, and one sign-out at a time.
///
/// It never navigates. A sign-out changes the Session, and the launch gate
/// moves the person to sign-in.
@injectable
class AccountCubit extends Cubit<AccountState> {
  new(this._repository)
    : super(
        AccountState.idle(switch (_repository.session) {
          SignedIn(:final profile) => profile,
          SignedOut() => const Profile(),
        }),
      );

  final AuthRepository _repository;

  Future<void> signOutRequested() async {
    if (state is AccountSigningOut) {
      return;
    }

    emit(AccountState.signingOut(state.profile));

    try {
      await _repository.signOut();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(AccountState.idle(state.profile));
    }
    // A sign-out that succeeds stays signingOut: the gate removes the modal,
    // so the button never flashes back to enabled.
  }
}
