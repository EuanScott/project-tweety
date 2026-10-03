import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

/// In-memory [AuthRepository], signed in by default so tests that do not care
/// about the launch gate land inside the app.
///
/// [signInResult] is what [signInWithGoogle] returns; a success also signs the
/// fake in. Pass a [Completer] through [pendingSignIn] to hold the attempt open
/// so a test can assert the in-progress state. [emit] changes the Session
/// mid-test, for example to sign out.
class FakeAuthRepository implements AuthRepository {
  new({
    this.session = const Session.signedIn(),
    this.signInResult = const SignInResult.succeeded(),
    this.pendingSignIn,
  });

  SignInResult signInResult;
  Completer<void>? pendingSignIn;
  int signInRequestCount = 0;

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
      emit(const Session.signedIn());
    }

    return signInResult;
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
