import 'package:injectable/injectable.dart';

import '../storage/app_preferences.storage.dart';

/// Orchestrates one-time initialization for app-level services.
///
/// This class exists to keep `bootstrap.dart` lean and predictable:
/// - `bootstrap.dart` should do *platform/framework* setup (e.g., Flutter bindings, Firebase),
///   then configure DI, then call into a single orchestrator.
/// - The orchestrator resolves and initializes services in a controlled order.
@singleton
class DiInitService {
  DiInitService(this._appPreferencesStorage);

  final AppPreferencesStorage _appPreferencesStorage;

  /// Initializes all registered app-level services.
  ///
  /// Notes on ordering:
  ///   - If one service depends on another, be sure to initialize that first, to prevent weird errors.
  Future<void> initializeAllServices() async {
    await _appPreferencesStorage.readPreferences();
  }
}
