import 'session.model.dart';
import 'sign_in_result.model.dart';

abstract class AuthRepository {
  /// The current Session.
  Session get session;

  /// Emits each new Session after it changes.
  Stream<Session> get sessionChanges;

  Future<SignInResult> signInWithGoogle();
}
