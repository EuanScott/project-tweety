import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';
import 'package:project_tweety/dev/auth/dev_auth.repository_impl.dart';

void main() {
  group('DevAuthRepository', () {
    test('is signed in once started, without a sign-in', () async {
      final AuthRepository repository = DevAuthRepository();

      await repository.start();

      expect(repository.session, isA<SignedIn>());
    });

    test('signs out and emits the SignedOut Session', () async {
      final AuthRepository repository = DevAuthRepository();
      await repository.start();
      final changes = <Session>[];
      repository.sessionChanges.listen(changes.add);

      await repository.signOut();

      expect(repository.session, const Session.signedOut());
      expect(changes, [const Session.signedOut()]);
    });

    test('signs back in without Google after a sign-out', () async {
      final AuthRepository repository = DevAuthRepository();
      await repository.start();
      await repository.signOut();
      final changes = <Session>[];
      repository.sessionChanges.listen(changes.add);

      final result = await repository.signInWithGoogle();

      expect(result, const SignInResult.succeeded());
      expect(repository.session, isA<SignedIn>());
      expect(changes.single, isA<SignedIn>());
    });
  });
}
