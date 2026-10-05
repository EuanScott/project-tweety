import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/presentation/widgets/account/account.cubit.dart';

import '../../../support/fake_auth_repository.dart';

void main() {
  const profile = Profile(displayName: 'Ada Lovelace');

  group('AccountCubit', () {
    test('starts idle with the Profile of the signed-in Session', () {
      final cubit = AccountCubit(FakeAuthRepository(profile: profile));
      addTearDown(cubit.close);

      expect(cubit.state, const AccountState.idle(profile));
    });

    test('starts with an empty Profile when signed out', () {
      final cubit = AccountCubit(
        FakeAuthRepository(session: const Session.signedOut()),
      );
      addTearDown(cubit.close);

      expect(cubit.state, const AccountState.idle(Profile()));
    });

    late FakeAuthRepository repository;

    blocTest<AccountCubit, AccountState>(
      'signing out moves to signingOut and calls the repository',
      setUp: () => repository = FakeAuthRepository(profile: profile),
      build: () => AccountCubit(repository),
      act: (cubit) => cubit.signOutRequested(),
      expect: () => const [AccountState.signingOut(profile)],
      verify: (_) {
        expect(repository.signOutRequestCount, 1);
        expect(repository.session, const Session.signedOut());
      },
    );

    blocTest<AccountCubit, AccountState>(
      'a sign-out that throws returns to idle',
      setUp: () =>
          repository = FakeAuthRepository(profile: profile)
            ..signOutError = Exception('offline'),
      build: () => AccountCubit(repository),
      act: (cubit) => cubit.signOutRequested(),
      expect: () => const [
        AccountState.signingOut(profile),
        AccountState.idle(profile),
      ],
      errors: () => [isA<Exception>()],
    );

    blocTest<AccountCubit, AccountState>(
      'ignores a second request while signing out',
      setUp: () =>
          repository = FakeAuthRepository(profile: profile)
            ..pendingSignOut = Completer<void>(),
      build: () => AccountCubit(repository),
      act: (cubit) async {
        unawaited(cubit.signOutRequested());
        await cubit.signOutRequested();
        repository.pendingSignOut!.complete();
      },
      expect: () => const [AccountState.signingOut(profile)],
      verify: (_) => expect(repository.signOutRequestCount, 1),
    );
  });
}
