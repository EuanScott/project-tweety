part of 'sign_in.cubit.dart';

/// Where the current sign-in attempt stands.
@freezed
sealed class SignInAttemptState with _$SignInAttemptState {
  const factory idle() = SignInAttemptIdle;

  const factory inProgress() = SignInAttemptInProgress;

  /// The last attempt failed. The failure stays until the next attempt starts.
  const factory failed(SignInFailure failure) = SignInAttemptFailed;
}
