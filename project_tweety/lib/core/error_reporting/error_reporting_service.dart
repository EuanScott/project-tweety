import 'dart:developer';
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

@LazySingleton(as: ErrorReportingService)
class FirebaseErrorReportingService implements ErrorReportingService {
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
