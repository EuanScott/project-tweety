import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../core/error_reporting/error_reporting.facade.dart';
import '../../repositories/auth/auth.repository.dart';
import '../../repositories/auth/session.model.dart';
import '../../repositories/log_entry/logs.repository.dart';

/// Starts a download each time the Session becomes signed in: at app start
/// with an Account already signed in, and at every new sign-in
/// ([ADR-0008](../../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)).
///
/// A failed download shows nothing. It is reported unless the Account could
/// not be reached or the Session changed during it, and the next start or
/// sign-in tries again. The repository
/// keeps downloads from overlapping each other or a sync.
@lazySingleton
class LogsDownloadTrigger(
  final AuthRepository _authRepository,
  final LogsRepository _logsRepository,
  final ErrorReportingFacade _errorReporting,
) {
  StreamSubscription<Session>? _subscription;

  /// Call once after the first frame, so startup never waits for a download.
  /// Later calls do nothing.
  void start() {
    if (_subscription != null) {
      return;
    }

    var wasSignedIn = _authRepository.session is SignedIn;
    _subscription = _authRepository.sessionChanges.listen((session) {
      final isSignedIn = session is SignedIn;
      if (isSignedIn && !wasSignedIn) {
        unawaited(_download());
      }
      wasSignedIn = isSignedIn;
    });
    if (wasSignedIn) {
      unawaited(_download());
    }
  }

  @disposeMethod
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _download() async {
    try {
      await _logsRepository.downloadLogs();
    } on LogsAccountUnreachableException {
      // Being offline is expected, not a fault. The next start retries.
    } on LogsSessionChangedException {
      // Signing out or switching Account is expected. The next sign-in
      // downloads again.
    } catch (error, stackTrace) {
      await _errorReporting.recordError(error, stackTrace);
    }
  }
}
