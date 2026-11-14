import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/dev/auth/dev_session_holder.datasource.dart';

void main() {
  group('DevSessionHolder', () {
    test('returns the dev uid while signed in', () {
      final holder = DevSessionHolder(isSignedIn: () => true);

      expect(holder.uid, 'dev-user');
    });

    test('throws when nobody is signed in', () {
      final holder = DevSessionHolder(isSignedIn: () => false);

      expect(() => holder.uid, throwsA(isA<AccountNotSignedInException>()));
    });

    test('reads the Session at call time, not at construction', () {
      var isSignedIn = true;
      final holder = DevSessionHolder(isSignedIn: () => isSignedIn);

      isSignedIn = false;

      expect(() => holder.uid, throwsA(isA<AccountNotSignedInException>()));
    });
  });
}
