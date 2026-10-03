import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_in_result.model.freezed.dart';

/// Why a sign-in attempt failed.
enum SignInFailure { network, other }

/// The outcome of one sign-in attempt.
@freezed
sealed class SignInResult with _$SignInResult {
  const factory succeeded() = SignInSucceeded;

  /// The person dismissed the identity provider's sign-in flow.
  const factory cancelled() = SignInCancelled;

  const factory failed(SignInFailure failure) = SignInFailed;
}
