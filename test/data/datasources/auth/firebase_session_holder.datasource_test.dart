import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/datasources/auth/firebase_session_holder.datasource.dart';

void main() {
  group('FirebaseSessionHolder', () {
    test('returns the uid of the signed-in Account', () {
      final firebaseAuth = _FakeFirebaseAuth()..currentUser = _FakeUser('a');

      expect(FirebaseSessionHolder(firebaseAuth).uid, 'a');
    });

    test('throws when nobody is signed in', () {
      final holder = FirebaseSessionHolder(_FakeFirebaseAuth());

      expect(() => holder.uid, throwsStateError);
    });

    test('reads the Account at call time, not at construction', () {
      final firebaseAuth = _FakeFirebaseAuth()..currentUser = _FakeUser('a');
      final holder = FirebaseSessionHolder(firebaseAuth);

      firebaseAuth.currentUser = _FakeUser('b');
      expect(holder.uid, 'b');

      firebaseAuth.currentUser = null;
      expect(() => holder.uid, throwsStateError);
    });
  });
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? currentUser;
}

class _FakeUser extends Fake implements User {
  new(this.uid);

  @override
  final String uid;
}
