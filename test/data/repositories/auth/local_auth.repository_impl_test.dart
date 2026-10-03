import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/local_auth.repository_impl.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';

void main() {
  group('LocalAuthRepository', () {
    test('starts signed out', () {
      final repository = LocalAuthRepository();

      expect(repository.session, const Session.signedOut());
    });

    test('signing in emits SignedIn and returns SignInSucceeded', () async {
      final repository = LocalAuthRepository();
      final emitted = <Session>[];
      final subscription = repository.sessionChanges.listen(emitted.add);
      addTearDown(subscription.cancel);

      final result = await repository.signInWithGoogle();
      await pumpEventQueue();

      expect(result, const SignInResult.succeeded());
      expect(repository.session, const Session.signedIn());
      expect(emitted, [const Session.signedIn()]);
    });
  });
}
