import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.service.dart';
import 'package:project_tweety/data/repositories/auth/firebase_auth.repository_impl.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

void main() {
  late _FakeFirebaseAuth firebaseAuth;
  late _FakeGoogleSignIn googleSignIn;
  late _RecordingErrorReportingService errorReporting;

  FirebaseAuthRepository buildRepository() => FirebaseAuthRepository(
    firebaseAuth,
    googleSignIn,
    ErrorReportingFacade([errorReporting]),
  );

  Future<FirebaseAuthRepository> startedRepository({User? user}) async {
    final repository = buildRepository();
    final started = repository.start();
    firebaseAuth.authStates.add(user);
    await started;

    return repository;
  }

  setUp(() {
    firebaseAuth = _FakeFirebaseAuth();
    googleSignIn = _FakeGoogleSignIn();
    errorReporting = _RecordingErrorReportingService();
  });

  group('FirebaseAuthRepository', () {
    group('start', () {
      test('initialises Google sign-in once', () async {
        await startedRepository();

        expect(googleSignIn.initializeCount, 1);
      });

      test('a remembered Account starts the app SignedIn with its '
          'Profile', () async {
        final repository = await startedRepository(user: _completeUser());

        expect(repository.session, Session.signedIn(_completeProfile));
      });

      test('no remembered Account starts the app SignedOut', () async {
        final repository = await startedRepository();

        expect(repository.session, const Session.signedOut());
      });

      test('no first auth event within 5 seconds starts SignedOut and reports '
          'the timeout', () {
        fakeAsync((async) {
          final repository = buildRepository();
          var started = false;
          unawaited(repository.start().then((_) => started = true));

          async.elapse(const Duration(milliseconds: 4999));
          expect(started, isFalse);

          async.elapse(const Duration(milliseconds: 1));
          expect(started, isTrue);
          expect(repository.session, const Session.signedOut());
          expect(errorReporting.errors.single, isA<TimeoutException>());
        });
      });

      test('an auth event after the timeout still updates the Session', () {
        fakeAsync((async) {
          final repository = buildRepository();
          unawaited(repository.start());
          async.elapse(const Duration(seconds: 5));

          firebaseAuth.authStates.add(_completeUser());
          async.flushMicrotasks();

          expect(repository.session, Session.signedIn(_completeProfile));
        });
      });

      test('a Google initialisation failure is reported and startup still '
          'finishes', () async {
        googleSignIn.initializeError = Exception('no client id');

        final repository = await startedRepository();

        expect(repository.session, const Session.signedOut());
        expect(errorReporting.errors, [googleSignIn.initializeError]);
      });
      test('a Google initialisation that never finishes still lets startup '
          'finish after 5 seconds', () {
        fakeAsync((async) {
          googleSignIn.pendingInitialize = Completer<void>();
          final repository = buildRepository();
          var started = false;
          unawaited(repository.start().then((_) => started = true));
          firebaseAuth.authStates.add(null);

          async.elapse(const Duration(seconds: 5));

          expect(started, isTrue);
          expect(errorReporting.errors.single, isA<TimeoutException>());
        });
      });
    });

    test('losing the Account while the app runs emits SignedOut', () async {
      final repository = await startedRepository(user: _completeUser());
      final emitted = <Session>[];
      final subscription = repository.sessionChanges.listen(emitted.add);
      addTearDown(subscription.cancel);

      firebaseAuth.authStates.add(null);
      await pumpEventQueue();

      expect(repository.session, const Session.signedOut());
      expect(emitted, [const Session.signedOut()]);
    });

    test('maps blank and missing User fields to a Profile with nothing '
        'known', () async {
      final repository = await startedRepository(
        user: _FakeUser(
          displayName: ' ',
          email: null,
          emailVerified: false,
          photoURL: '',
          phoneNumber: null,
        ),
      );

      expect(
        repository.session,
        const Session.signedIn(Profile(displayName: ' ')),
      );
    });

    group('signInWithGoogle', () {
      test('exchanges the Google ID token for a Firebase sign-in, then emits '
          'SignedIn with the Profile', () async {
        final repository = await startedRepository();
        firebaseAuth.signInUser = _completeUser();
        final emitted = <Session>[];
        final subscription = repository.sessionChanges.listen(emitted.add);
        addTearDown(subscription.cancel);

        final result = await repository.signInWithGoogle();
        await pumpEventQueue();

        expect(result, const SignInResult.succeeded());
        expect(
          (firebaseAuth.signInCredential! as OAuthCredential).idToken,
          _FakeGoogleSignIn.idToken,
        );
        expect(repository.session, Session.signedIn(_completeProfile));
        expect(emitted, [Session.signedIn(_completeProfile)]);
      });

      test('the auth event that follows a sign-in does not emit the same '
          'Session twice', () async {
        final repository = await startedRepository();
        firebaseAuth.signInUser = _completeUser();
        final emitted = <Session>[];
        final subscription = repository.sessionChanges.listen(emitted.add);
        addTearDown(subscription.cancel);

        await repository.signInWithGoogle();
        firebaseAuth.authStates.add(_completeUser());
        await pumpEventQueue();

        expect(emitted, [Session.signedIn(_completeProfile)]);
      });

      test('a Firebase sign-in with no user returns other and is '
          'reported', () async {
        final repository = await startedRepository();

        final result = await repository.signInWithGoogle();

        expect(result, const SignInResult.failed(SignInFailure.other));
        expect(repository.session, const Session.signedOut());
        expect(errorReporting.errors.single, isA<StateError>());
      });

      test('a cancelled Google flow returns SignInCancelled, reports nothing '
          'and leaves the Session SignedOut', () async {
        final repository = await startedRepository();
        googleSignIn.authenticateError = const GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
        );

        final result = await repository.signInWithGoogle();

        expect(result, const SignInResult.cancelled());
        expect(repository.session, const Session.signedOut());
        expect(errorReporting.errors, isEmpty);
      });

      test('any other Google failure returns other and is reported', () async {
        final repository = await startedRepository();
        googleSignIn.authenticateError = const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        );

        final result = await repository.signInWithGoogle();

        expect(result, const SignInResult.failed(SignInFailure.other));
        expect(errorReporting.errors, [googleSignIn.authenticateError]);
        expect(errorReporting.codes, ['clientConfigurationError']);
      });

      test('a Firebase network failure returns network and is '
          'reported', () async {
        final repository = await startedRepository();
        firebaseAuth.signInError = FirebaseAuthException(
          code: 'network-request-failed',
        );

        final result = await repository.signInWithGoogle();

        expect(result, const SignInResult.failed(SignInFailure.network));
        expect(errorReporting.errors, [firebaseAuth.signInError]);
        expect(errorReporting.codes, ['network-request-failed']);
      });

      test(
        'any other Firebase failure returns other and is reported',
        () async {
          final repository = await startedRepository();
          firebaseAuth.signInError = FirebaseAuthException(
            code: 'user-disabled',
          );

          final result = await repository.signInWithGoogle();

          expect(result, const SignInResult.failed(SignInFailure.other));
          expect(errorReporting.errors, [firebaseAuth.signInError]);
        },
      );
    });

    group('signOut', () {
      test('signs out of Firebase and Google, then emits SignedOut', () async {
        final repository = await startedRepository(user: _completeUser());
        final emitted = <Session>[];
        final subscription = repository.sessionChanges.listen(emitted.add);
        addTearDown(subscription.cancel);

        await repository.signOut();
        await pumpEventQueue();

        expect(firebaseAuth.signOutCount, 1);
        expect(googleSignIn.signOutCount, 1);
        expect(repository.session, const Session.signedOut());
        expect(emitted, [const Session.signedOut()]);
      });

      test('a Google sign-out failure is reported and the Session still '
          'ends', () async {
        final repository = await startedRepository(user: _completeUser());
        googleSignIn.signOutError = Exception('channel closed');

        await repository.signOut();

        expect(repository.session, const Session.signedOut());
        expect(errorReporting.errors, [googleSignIn.signOutError]);
      });
    });
  });
}

final _completeProfile = Profile(
  displayName: 'Ada Lovelace',
  email: 'ada@example.com',
  isEmailVerified: true,
  photoUrl: Uri.parse('https://example.com/ada.png'),
  phoneNumber: '+27 82 000 0000',
);

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  // Single-subscription, so events added before the repository listens are
  // buffered. Never closed: closing an unlistened controller never completes.
  // ignore: close_sinks
  final authStates = StreamController<User?>();

  User? signInUser;
  FirebaseAuthException? signInError;
  AuthCredential? signInCredential;
  int signOutCount = 0;

  @override
  Stream<User?> authStateChanges() => authStates.stream;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    signInCredential = credential;
    if (signInError case final error?) {
      throw error;
    }

    return _FakeUserCredential(signInUser);
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
  }
}

class _FakeUser extends Fake implements User {
  new({
    required this.displayName,
    required this.email,
    required this.emailVerified,
    required this.photoURL,
    required this.phoneNumber,
  });

  @override
  final String? displayName;

  @override
  final String? email;

  @override
  final bool emailVerified;

  @override
  final String? photoURL;

  @override
  final String? phoneNumber;
}

_FakeUser _completeUser() => _FakeUser(
  displayName: 'Ada Lovelace',
  email: 'ada@example.com',
  emailVerified: true,
  photoURL: 'https://example.com/ada.png',
  phoneNumber: '+27 82 000 0000',
);

class _FakeUserCredential extends Fake implements UserCredential {
  new(this.user);

  @override
  final User? user;
}

class _FakeGoogleSignIn extends Fake implements GoogleSignIn {
  static const idToken = 'google-id-token';

  Exception? initializeError;
  Completer<void>? pendingInitialize;
  GoogleSignInException? authenticateError;
  Exception? signOutError;
  int initializeCount = 0;
  int signOutCount = 0;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    initializeCount++;
    await pendingInitialize?.future;
    if (initializeError case final error?) {
      throw error;
    }
  }

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    if (authenticateError case final error?) {
      throw error;
    }

    return _FakeGoogleSignInAccount();
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
    if (signOutError case final error?) {
      throw error;
    }
  }
}

class _FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  GoogleSignInAuthentication get authentication =>
      const GoogleSignInAuthentication(idToken: _FakeGoogleSignIn.idToken);
}

class _RecordingErrorReportingService extends Fake
    implements ErrorReportingService {
  final errors = <Object>[];
  final codes = <Object?>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    errors.add(error);
    codes.add(metadata?['code']);
  }
}
