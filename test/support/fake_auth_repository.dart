import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

/// In-memory [AuthRepository], signed in by default so tests that do not care
/// about the launch gate land inside the app.
///
/// [signInResult] is what [signInWithGoogle] returns; a success also signs the
/// fake in. Pass a [Completer] through [pendingSignIn] to hold the attempt open
/// so a test can assert the in-progress state. [profile] is the Profile a
/// signed-in Session carries. [signOut] signs the fake out and counts the
/// call; pass a [Completer] through [pendingSignOut] to hold it open, or set
/// [signOutError] to make it throw. [emit] changes the Session mid-test.
class FakeAuthRepository implements AuthRepository {
  new({
    this.profile = const Profile(),
    Session? session,
    this.signInResult = const SignInResult.succeeded(),
    this.pendingSignIn,
    this.pendingSignOut,
    this.signOutError,
  }) : session = session ?? Session.signedIn(profile);

  final Profile profile;
  SignInResult signInResult;
  Completer<void>? pendingSignIn;
  Completer<void>? pendingSignOut;
  Exception? signOutError;
  int signInRequestCount = 0;
  int signOutRequestCount = 0;

  final _sessionChanges = StreamController<Session>.broadcast();

  @override
  Session session;

  @override
  Stream<Session> get sessionChanges => _sessionChanges.stream;

  @override
  Future<SignInResult> signInWithGoogle() async {
    signInRequestCount++;
    await pendingSignIn?.future;

    if (signInResult case SignInSucceeded()) {
      emit(Session.signedIn(profile));
    }

    return signInResult;
  }

  @override
  Future<void> signOut() async {
    signOutRequestCount++;
    await pendingSignOut?.future;

    if (signOutError case final error?) {
      throw error;
    }

    emit(const Session.signedOut());
  }

  void emit(Session session) {
    this.session = session;
    _sessionChanges.add(session);
  }
}

/// Swaps the registered [AuthRepository] for [repository].
void replaceAuthRepository(AuthRepository repository) {
  GetIt.I
    // GetIt.unregister returns FutureOr and completes synchronously here:
    // the fakes register no async disposers, so there is no future to await.
    // ignore: discarded_futures
    ..unregister<AuthRepository>()
    ..registerSingleton<AuthRepository>(repository);
}
