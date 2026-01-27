import 'package:injectable/injectable.dart';
import 'error_reporting_service.dart';

@lazySingleton
class ErrorReportingFacade {
  ErrorReportingFacade(this._services);

  final Iterable<ErrorReportingService> _services;

  Future<void> setUserId(String userId) async {
    for (final s in _services) {
      try {
        await s.setUserId(userId);
      } catch (_) {}
    }
  }

  Future<void> clearUserId() async {
    for (final s in _services) {
      try {
        await s.clearUserId();
      } catch (_) {}
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    for (final s in _services) {
      try {
        await s.recordError(
          error,
          stackTrace,
          metadata: metadata,
          fatal: fatal,
        );
      } catch (_) {}
    }
  }
}
