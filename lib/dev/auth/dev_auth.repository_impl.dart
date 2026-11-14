import 'dart:async';

import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

/// A Session for local development that never reaches Firebase or Google.
///
/// It starts signed in as a made-up Account, so the app opens past the
/// sign-in page on any emulator or simulator.
class DevAuthRepository implements AuthRepository {
  static const profile = Profile(
    displayName: 'Dev User',
    email: 'dev@example.com',
    isEmailVerified: true,
  );

  final _sessionChanges = StreamController<Session>.broadcast();

  Session _session = const Session.signedIn(profile);

  @override
  Session get session => _session;

  @override
  Stream<Session> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> start() async {}

  @override
  Future<SignInResult> signInWithGoogle() async {
    _setSession(const Session.signedIn(profile));

    return const SignInResult.succeeded();
  }

  @override
  Future<void> signOut() async => _setSession(const Session.signedOut());

  void _setSession(Session session) {
    _session = session;
    _sessionChanges.add(session);
  }
}
