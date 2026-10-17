import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.service.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/data/services/log_entry/logs_download_trigger.service.dart';

import '../../../support/fake_auth_repository.dart';
import '../../../support/fake_logs_repository.dart';

void main() {
  group('LogsDownloadTrigger', () {
    late FakeAuthRepository auth;
    late FakeLogsRepository logs;
    late _RecordingErrorReportingService errorReporting;
    late LogsDownloadTrigger trigger;

    setUp(() {
      auth = FakeAuthRepository();
      logs = FakeLogsRepository();
      errorReporting = _RecordingErrorReportingService();
      trigger = LogsDownloadTrigger(
        auth,
        logs,
        ErrorReportingFacade([errorReporting]),
      );
    });

    tearDown(() => trigger.dispose());

    test(
      'starts one download when started with an Account signed in',
      () async {
        trigger.start();
        await pumpEventQueue();

        expect(logs.downloadRequestCount, 1);
      },
    );

    test('starts no download while signed out, and one when an Account '
        'signs in', () async {
      auth.session = const Session.signedOut();
      trigger.start();
      await pumpEventQueue();
      expect(logs.downloadRequestCount, 0);

      auth.emit(const Session.signedIn(Profile()));
      await pumpEventQueue();

      expect(logs.downloadRequestCount, 1);
    });

    test('starts one more download each time the Session becomes signed '
        'in again', () async {
      trigger.start();
      auth
        ..emit(const Session.signedOut())
        ..emit(const Session.signedIn(Profile()));
      await pumpEventQueue();

      expect(logs.downloadRequestCount, 2);
    });

    test('a Session that changes but stays signed in starts no '
        'download', () async {
      trigger.start();
      auth.emit(const Session.signedIn(Profile(displayName: 'Renamed')));
      await pumpEventQueue();

      expect(logs.downloadRequestCount, 1);
    });

    test('starting again does nothing', () async {
      trigger
        ..start()
        ..start();
      auth
        ..emit(const Session.signedOut())
        ..emit(const Session.signedIn(Profile()));
      await pumpEventQueue();

      expect(logs.downloadRequestCount, 2);
    });

    test('an unreachable Account is not reported', () async {
      logs.downloadError = const LogsAccountUnreachableException();

      trigger.start();
      await pumpEventQueue();

      expect(errorReporting.errors, isEmpty);
    });

    test('a Session that signed out or changed Account during the download '
        'is not reported', () async {
      logs.downloadError = const LogsSessionChangedException();

      trigger.start();
      await pumpEventQueue();

      expect(errorReporting.errors, isEmpty);
    });

    test('any other failure is reported, and the next sign-in tries '
        'again', () async {
      final error = StateError('refused');
      logs.downloadError = error;

      trigger.start();
      await pumpEventQueue();
      logs.downloadError = null;
      auth
        ..emit(const Session.signedOut())
        ..emit(const Session.signedIn(Profile()));
      await pumpEventQueue();

      expect(errorReporting.errors, [error]);
      expect(logs.downloadRequestCount, 2);
    });

    test('stops listening when disposed', () async {
      auth.session = const Session.signedOut();
      trigger.start();
      await trigger.dispose();

      auth.emit(const Session.signedIn(Profile()));
      await pumpEventQueue();

      expect(logs.downloadRequestCount, 0);
    });
  });
}

class _RecordingErrorReportingService extends Fake
    implements ErrorReportingService {
  final errors = <Object>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    errors.add(error);
  }
}
