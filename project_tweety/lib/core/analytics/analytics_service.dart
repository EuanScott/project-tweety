import 'dart:developer';
import 'dart:io' show Platform;

// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AnalyticsModule {
  @lazySingleton
  Iterable<AnalyticsService> get analyticsServices =>
      GetIt.I.getAll<AnalyticsService>();

  @lazySingleton
  Iterable<FirebaseErrorReportingService> get errorReportingServices =>
      GetIt.I.getAll<FirebaseErrorReportingService>();
}

@lazySingleton
class AnalyticsFacade {
  AnalyticsFacade(
    Iterable<AnalyticsService> analyticsServices,
    Iterable<FirebaseErrorReportingService> errorReportingServices,
  ) : _errorReportingServices = errorReportingServices,
      _analyticsServices = analyticsServices;

  final Iterable<AnalyticsService> _analyticsServices;
  final Iterable<FirebaseErrorReportingService> _errorReportingServices;

  Future<void> setUserId(String userId) async {
    for (final service in _analyticsServices) {
      try {
        await service.setUserId(userId);
      } catch(_) {
        // log for dev purposes
      }
    }

    for (final service in _errorReportingServices) {
      try {
        await service.setUserId(userId);
      } catch(_) {
        // log for dev purposes
      }
    }
  }

  Future<void> trackEvent(String eventName, Map<String, Object?>? params) async {
    for (final service in _analyticsServices) {
      try {
        await service.trackEvent(eventName, params);
      } catch(_) {
        // log for dev purposes
      }
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
  }) async {
    for (final service in _errorReportingServices) {
      try {
        await service.recordError(error, stackTrace, metadata: metadata);
      } catch(_) {
        // log for dev purposes
      }
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    for (final service in _analyticsServices) {
      await service.logScreenView(screenName, screenClass);
    }
    for (final service in _errorReportingServices) {
      await service.logScreenView(screenName, screenClass);
    }
  }
}

abstract class AnalyticsService {
  Future<void> setUserId(String userId);

  Future<void> trackEvent(String eventName, Map<String, Object?>? params);

  Future<void> logScreenView(String screenName, String? screenClass);
}

//#region Firebase Analytics

@Named('firebaseAnalytics')
@LazySingleton(as: AnalyticsService)
class FirebaseServiceImpl implements AnalyticsService {
  FirebaseServiceImpl({
    required this.appInfoProvider,
    required this.platformInfoProvider,
    required this.screenContextStore,
  });

  final AppInfoProvider appInfoProvider;
  final PlatformInfoProvider platformInfoProvider;
  final ScreenContextStore screenContextStore;

  @override
  Future<void> setUserId(String userId) async {
    log('Set UserId: $userId');
  }

  @override
  Future<void> trackEvent(String name, Map<String, Object?>? params) async {
    final enrichedParams = <String, Object?>{
      if (params != null) ...params,
      'app_version': await appInfoProvider.getAppVersion(),
      'platform': await platformInfoProvider.detectPlatform(),
    };

    final screen = screenContextStore.currentScreen;
    if (screen != null) {
      enrichedParams['screen_name'] = screen;
    }

    log('LogEvent: name - $name, parameters: $enrichedParams');

    // await FirebaseAnalytics.instance.trackEvent(
    //   name: name,
    //   parameters: enrichedParams,
    // );
  }

  @override
  Future<void> logScreenView(String screenName, String? screenClass) async {
    log('LogScreenView: screenName - $screenName, screenClass: $screenClass');
    // await FirebaseAnalytics.instance.logScreenView(
    //   screenName: screenName,
    //   screenClass: screenClass,
    // );
  }
}

//#endregion

abstract class FirebaseErrorReportingService {
  Future<void> setUserId(String userId);

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    Map<String, Object?>? metadata,
  });

  Future<void> logScreenView(String screenName, String? screenClass);
}

//#region Firebase Crashlytics

@Named('firebaseErrorReportingService')
@LazySingleton(as: FirebaseErrorReportingService)
class FirebaseErrorReportingServiceImpl implements FirebaseErrorReportingService {
  FirebaseErrorReportingServiceImpl();

  @override
  Future<void> setUserId(String userId) async {
    log('Set UserId: $userId');
    // await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  @override
  Future<void> recordError(
      Object error,
      StackTrace? stackTrace, {
        Map<String, Object?>? metadata,
      }
  ) async {
    final flutterErrorDetails = FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
    );
    log('Non-fatal error - $flutterErrorDetails');
    // await FirebaseCrashlytics.instance.recordFlutterError(flutterErrorDetails);
  }

  @override
  Future<void> logScreenView(String screenName, String? screenClass) async {
    // no-op
    return;
  }
}

//#endregion

//#region Analytics Helpers

abstract class AppInfoProvider {
  Future<String> getAppVersion();
}

@LazySingleton(as: AppInfoProvider)
class AppInfoProviderImpl implements AppInfoProvider {
  AppInfoProviderImpl();

  @override
  Future<String> getAppVersion() async {
    return 'TODO: AppVersion';
  }
}

abstract class PlatformInfoProvider {
  Future<String> detectPlatform();
}

@LazySingleton(as: PlatformInfoProvider)
class PlatformInfoProviderImpl implements PlatformInfoProvider {
  PlatformInfoProviderImpl();

  @override
  Future<String> detectPlatform() async {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return Platform.operatingSystem;
    }
  }
}

//#endregion

//#region Page Name Tracking

abstract class ScreenContextStore {
  String? get currentScreen;

  void updateScreen(String screenName);
}

@LazySingleton(as: ScreenContextStore)
class InAppScreenView implements ScreenContextStore {
  String? _currentScreen;

  @override
  String? get currentScreen => _currentScreen;

  @override
  void updateScreen(String screenName) {
    _currentScreen = screenName;
  }
}

//#endregion
