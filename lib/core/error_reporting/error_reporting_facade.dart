import 'package:injectable/injectable.dart';

import 'error_reporting_service.dart';

@lazySingleton
class ErrorReportingFacade {
  ErrorReportingFacade(Iterable<ErrorReportingService> services)
    : _services = List.unmodifiable(services);

  final List<ErrorReportingService> _services;

  Future<void> setUserId(String userId) async {
    await Future.wait(
      _services.map((s) async {
        try {
          await s.setUserId(userId);
        } catch (_) {}
      }),
    );
  }

  Future<void> clearUserId() async {
    await Future.wait(
      _services.map((s) async {
        try {
          await s.clearUserId();
        } catch (_) {}
      }),
    );
  }

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
    bool fatal = false,
  }) async {
    await Future.wait(
      _services.map((s) async {
        try {
          await s.recordError(
            error,
            stackTrace,
            metadata: metadata,
            fatal: fatal,
          );
        } catch (_) {}
      }),
    );
  }
}

@module
abstract class ErrorReportingModule {
  @lazySingleton
  Iterable<ErrorReportingService> errorReportingServices(
    @Named('crashlytics') ErrorReportingService crashlytics,
    @Named('coralogix') ErrorReportingService coralogix,
  ) => <ErrorReportingService>[crashlytics, coralogix];
}
