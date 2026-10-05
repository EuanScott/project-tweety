part of 'account.cubit.dart';

/// Whether a sign-out is under way, and whose Profile is shown.
@freezed
sealed class AccountState with _$AccountState {
  const factory idle(Profile profile) = AccountIdle;

  const factory signingOut(Profile profile) = AccountSigningOut;
}
