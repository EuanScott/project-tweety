import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error_reporting/error_reporting.facade.dart';
import 'auth.repository.dart';
import 'profile.model.dart';
import 'session.model.dart';
import 'sign_in_result.model.dart';

/// The Session as Firebase Auth knows it, signed in through Google.
///
/// Google sign-in only proves who the person is. Its ID token is exchanged
/// for a Firebase sign-in, and Firebase owns the Session from then on,
/// including keeping it across app restarts. It lives as long as the app, so
/// its auth-state subscription is never cancelled.
@LazySingleton(as: AuthRepository)
class FirebaseAuthRepository implements AuthRepository {
  new(this._firebaseAuth, this._googleSignIn, this._errorReporting);

  static const _startTimeout = Duration(seconds: 5);
  static const _networkErrorCode = 'network-request-failed';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ErrorReportingFacade _errorReporting;
  final _sessionChanges = StreamController<Session>.broadcast();

  Session _session = const Session.signedOut();

  @override
  Session get session => _session;

  @override
  Stream<Session> get sessionChanges => _sessionChanges.stream;

  @override
  Future<void> start() async {
    final firstEvent = Completer<void>();
    _firebaseAuth.authStateChanges().listen((user) {
      _setSession(_sessionFor(user));
      if (!firstEvent.isCompleted) {
        firstEvent.complete();
      }
    });

    try {
      await Future.wait([_initializeGoogleSignIn(), firstEvent.future])
          .timeout(_startTimeout);
    } on TimeoutException catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  @override
  Future<SignInResult> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      final user = (await _firebaseAuth.signInWithCredential(credential)).user;
      if (user == null) {
        _report(StateError('Firebase sign-in returned no user'), null);

        return const SignInResult.failed(SignInFailure.other);
      }

      _setSession(_sessionFor(user));

      return const SignInResult.succeeded();
    } on GoogleSignInException catch (error, stackTrace) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return const SignInResult.cancelled();
      }

      _report(error, stackTrace, code: error.code.name);

      return const SignInResult.failed(SignInFailure.other);
    } on FirebaseAuthException catch (error, stackTrace) {
      _report(error, stackTrace, code: error.code);

      return SignInResult.failed(
        error.code == _networkErrorCode
            ? SignInFailure.network
            : SignInFailure.other,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      // The Session is already over. A Google session left behind only skips
      // the account chooser on the next sign-in.
      _report(error, stackTrace);
    }
    _setSession(const Session.signedOut());
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (error, stackTrace) {
      _report(error, stackTrace);
    }
  }

  void _report(Object error, StackTrace? stackTrace, {String? code}) {
    unawaited(
      _errorReporting.recordError(
        error,
        stackTrace,
        metadata: code == null ? null : {'code': code},
      ),
    );
  }

  void _setSession(Session session) {
    if (session == _session) {
      return;
    }

    _session = session;
    _sessionChanges.add(session);
  }

  static Session _sessionFor(User? user) {
    if (user == null) {
      return const Session.signedOut();
    }

    final photoUrl = user.photoURL;

    return Session.signedIn(
      Profile(
        displayName: user.displayName,
        email: user.email,
        isEmailVerified: user.emailVerified,
        photoUrl: photoUrl == null || photoUrl.trim().isEmpty
            ? null
            : Uri.tryParse(photoUrl),
        phoneNumber: user.phoneNumber,
      ),
    );
  }
}
