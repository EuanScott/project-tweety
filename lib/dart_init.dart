import 'package:get_it/get_it.dart';

import 'core/di/dependency_injection.dart';
import 'core/di/di_init_service.dart';

Future<void> dartInit() async {
  // Configure DI
  await configureCoreDependencies();

  // Initialize Firebase pre-DI
  // await Firebase().initialize();

  // Initialize all app-level services via the di orchestrator
  final initializer = GetIt.instance<DiInitService>();
  await initializer.initializeAllServices();
}
