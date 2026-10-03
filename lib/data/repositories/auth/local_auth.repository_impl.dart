import 'dart:async';

import 'package:injectable/injectable.dart';

import 'auth.repository.dart';
import 'session.model.dart';
import 'sign_in_result.model.dart';

/// The app's identity source until the Firebase implementation replaces it.
///
/// It keeps the Session on this device only, with no identity provider behind
/// it. Every launch starts signed out, because nothing is persisted, and
/// signing in always succeeds. It is not a test double and not a prototype.
@LazySingleton(as: AuthRepository)
class LocalAuthRepository implements AuthRepository {
  final _sessionChanges = StreamController<Session>.broadcast();

  Session _session = const Session.signedOut();

  @override
  Session get session => _session;

  @override
  Stream<Session> get sessionChanges => _sessionChanges.stream;

  @override
  Future<SignInResult> signInWithGoogle() async {
    _session = const Session.signedIn();
    _sessionChanges.add(_session);

    return const SignInResult.succeeded();
  }
}
