import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';
import 'package:project_tweety/presentation/pages/sign_in/cubit/sign_in.cubit.dart';

import '../../../../support/fake_auth_repository.dart';

void main() {
  FakeAuthRepository signedOutRepository({
    SignInResult result = const SignInResult.succeeded(),
    Completer<void>? pendingSignIn,
  }) {
    return FakeAuthRepository(
      session: const Session.signedOut(),
      signInResult: result,
      pendingSignIn: pendingSignIn,
    );
  }

  group('SignInCubit', () {
    test('starts idle', () {
      expect(
        SignInCubit(signedOutRepository()).state,
        const SignInAttemptState.idle(),
      );
    });

    blocTest<SignInCubit, SignInAttemptState>(
      'a success stays in progress so the gate can move the person on',
      build: () => SignInCubit(signedOutRepository()),
      act: (cubit) => cubit.signInRequested(),
      expect: () => const [SignInAttemptState.inProgress()],
    );

    blocTest<SignInCubit, SignInAttemptState>(
      'a network failure is kept',
      build: () => SignInCubit(
        signedOutRepository(
          result: const SignInResult.failed(SignInFailure.network),
        ),
      ),
      act: (cubit) => cubit.signInRequested(),
      expect: () => const [
        SignInAttemptState.inProgress(),
        SignInAttemptState.failed(SignInFailure.network),
      ],
    );

    blocTest<SignInCubit, SignInAttemptState>(
      'any other failure is kept',
      build: () => SignInCubit(
        signedOutRepository(
          result: const SignInResult.failed(SignInFailure.other),
        ),
      ),
      act: (cubit) => cubit.signInRequested(),
      expect: () => const [
        SignInAttemptState.inProgress(),
        SignInAttemptState.failed(SignInFailure.other),
      ],
    );

    blocTest<SignInCubit, SignInAttemptState>(
      'a cancelled attempt returns to idle',
      build: () => SignInCubit(
        signedOutRepository(result: const SignInResult.cancelled()),
      ),
      act: (cubit) => cubit.signInRequested(),
      expect: () => const [
        SignInAttemptState.inProgress(),
        SignInAttemptState.idle(),
      ],
    );

    final pending = Completer<void>();
    final repository = signedOutRepository(
      result: const SignInResult.failed(SignInFailure.network),
      pendingSignIn: pending,
    );
    blocTest<SignInCubit, SignInAttemptState>(
      'a second request while in progress is ignored',
      build: () => SignInCubit(repository),
      act: (cubit) async {
        final first = cubit.signInRequested();
        final second = cubit.signInRequested();
        pending.complete();
        await Future.wait([first, second]);
      },
      expect: () => const [
        SignInAttemptState.inProgress(),
        SignInAttemptState.failed(SignInFailure.network),
      ],
      verify: (_) => expect(repository.signInRequestCount, 1),
    );

    blocTest<SignInCubit, SignInAttemptState>(
      'a retry from a failure starts a new attempt',
      build: () => SignInCubit(signedOutRepository()),
      seed: () => const SignInAttemptState.failed(SignInFailure.network),
      act: (cubit) => cubit.signInRequested(),
      expect: () => const [SignInAttemptState.inProgress()],
    );
  });
}
