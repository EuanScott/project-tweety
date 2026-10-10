import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'session_holder.datasource.dart';

@LazySingleton(as: SessionHolder)
class const FirebaseSessionHolder(final FirebaseAuth _firebaseAuth)
    implements SessionHolder {
  @override
  String get uid =>
      _firebaseAuth.currentUser?.uid ??
      (throw StateError('No Account is signed in'));
}
