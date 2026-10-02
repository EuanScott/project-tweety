import 'package:injectable/injectable.dart';

import 'error_reporting.service.dart';

@module
abstract class ErrorReportingModule {
  @lazySingleton
  Iterable<ErrorReportingService> errorReportingServices(
    @Named('crashlytics') ErrorReportingService crashlytics,
    @Named('coralogix') ErrorReportingService coralogix,
  ) => <ErrorReportingService>[crashlytics, coralogix];
}
