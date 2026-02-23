import 'dart:developer';

// import 'package:cx_flutter_plugin/cx_flutter_plugin.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';

abstract class ErrorReportingService {
  Future<void> setUserId(String userId);

  Future<void> clearUserId();

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  });
}

@Named('crashlytics')
@LazySingleton(as: ErrorReportingService)
class FirebaseErrorReportingService implements ErrorReportingService {
  FirebaseErrorReportingService(/*this._crashlytics*/);

  // final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> setUserId(String userId) async {
    log('[Crashlytics] setUserId: $userId');
  }

  @override
  Future<void> clearUserId() async {
    log('[Crashlytics] clearUserId');
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    log('[Crashlytics] error: $error fatal=$fatal');
  }
}

@Named('coralogix')
@LazySingleton(as: ErrorReportingService)
class CoralogixErrorReportingService implements ErrorReportingService {
  CoralogixErrorReportingService(/*this._cx*/);

  // final CxFlutterPlugin _cx;

  @override
  Future<void> setUserId(String userId) async {
    // Depending on how you model RUM, you might set a user context here.
    // Keeping it as a log for now (pseudo-code).
    log('[Coralogix] setUserId: $userId');
  }

  @override
  Future<void> clearUserId() async {
    log('[Coralogix] clearUserId');
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    // Pseudo-code: send an error/exception signal to Coralogix.
    // Wire this up to Coralogix RUM / logs once you decide the exact event API you want.
    log('[Coralogix] error: $error fatal=$fatal metadata=$metadata');
  }
}
