import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import 'core/di/dependency_injection.dart';
import 'core/di/di_init.service.dart';
import 'core/firebase/firebase_options.constants.dart';

/// [replaceDependencies] runs after DI is configured and before any service
/// starts, so an entrypoint can swap a registration before it is first used.
Future<void> dartInit({
  FutureOr<void> Function(GetIt getIt)? replaceDependencies,
}) async {
  // Initialize Firebase pre-DI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure DI
  await configureCoreDependencies();
  await replaceDependencies?.call(GetIt.instance);

  // Initialize all app-level services via the di orchestrator
  final initializer = GetIt.instance<DiInitService>();
  await initializer.initializeAllServices();
}
