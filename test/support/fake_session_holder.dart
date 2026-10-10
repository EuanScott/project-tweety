import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';

/// [SessionHolder] for datasource tests. Set [signedInUid] to null to act as
/// if nobody is signed in.
class FakeSessionHolder implements SessionHolder {
  new([this.signedInUid = 'account-a']);

  String? signedInUid;

  @override
  String get uid =>
      signedInUid ?? (throw StateError('No Account is signed in'));
}
