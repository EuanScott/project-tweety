import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';

/// The dev Account's fixed uid, for local development without Firebase.
///
/// [isSignedIn] is read at query time, so a sign-out in the app ends access
/// the same way it does for the Firebase Account.
class const DevSessionHolder({required final bool Function() isSignedIn})
    implements SessionHolder {
  static const devUid = 'dev-user';

  @override
  String get uid => isSignedIn()
      ? devUid
      : (throw const AccountNotSignedInException('No Account is signed in'));
}
