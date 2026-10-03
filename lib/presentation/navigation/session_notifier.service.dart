import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';

/// The router's view of the Session: the current value for the launch gate's
/// redirect, and a notification each time it changes so the gate re-runs.
///
/// Whoever owns the router owns this too, and disposes it with the router.
class SessionNotifier extends ChangeNotifier {
  new(AuthRepository repository) : _repository = repository {
    _subscription = repository.sessionChanges.listen((_) => notifyListeners());
  }

  final AuthRepository _repository;
  late final StreamSubscription<Session> _subscription;

  Session get session => _repository.session;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
