import 'dart:async';

import 'package:injectable/injectable.dart';

import 'auth.repository.dart';
import 'profile.model.dart';
import 'session.model.dart';
import 'sign_in_result.model.dart';

/// The app's identity source until the Firebase implementation replaces it.
///
/// It keeps the Session on this device only, with no identity provider behind
/// it. Every launch starts signed out, because nothing is persisted, and
/// signing in always succeeds. With no identity provider, the Profile is
/// empty, and signing out cannot fail. It is not a test double and not a
/// prototype.
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
    _setSession(const Session.signedIn(Profile()));

    return const SignInResult.succeeded();
  }

  @override
  Future<void> signOut() async {
    _setSession(const Session.signedOut());
  }

  void _setSession(Session session) {
    _session = session;
    _sessionChanges.add(session);
  }
}
