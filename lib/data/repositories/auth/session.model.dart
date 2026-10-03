import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.model.freezed.dart';

/// Whether a person is signed in on this device.
///
/// There is no unknown state: the app always knows which of the two it is.
@freezed
sealed class Session with _$Session {
  const factory signedOut() = SignedOut;

  const factory signedIn() = SignedIn;
}
