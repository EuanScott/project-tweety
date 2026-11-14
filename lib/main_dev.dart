import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/dart_init.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/repositories/auth/auth.repository.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/dev/auth/dev_auth.repository_impl.dart';
import 'package:project_tweety/dev/auth/dev_session_holder.datasource.dart';
import 'package:project_tweety/dev/log_entry/dev_logs_remote.datasource.dart';
import 'package:project_tweety/main.dart';

/// Starts the app signed in as a made-up dev Account, with no Google sign-in
/// and no Firestore: `flutter run -t lib/main_dev.dart`.
///
/// Debug builds only. Release builds start from `lib/main.dart`, which never
/// imports this file.
Future<void> main() async {
  if (!kDebugMode) {
    throw StateError('lib/main_dev.dart runs only in debug builds');
  }

  WidgetsFlutterBinding.ensureInitialized();

  await dartInit(replaceDependencies: _registerDevDependencies);

  runApp(const MyApp());
}

Future<void> _registerDevDependencies(GetIt getIt) async {
  final auth = DevAuthRepository();

  await getIt.unregister<AuthRepository>();
  getIt.registerSingleton<AuthRepository>(auth);
  await getIt.unregister<SessionHolder>();
  getIt.registerSingleton<SessionHolder>(
    DevSessionHolder(isSignedIn: () => auth.session is SignedIn),
  );
  await getIt.unregister<LogsRemoteDataSource>();
  getIt.registerSingleton<LogsRemoteDataSource>(
    const DevLogsRemoteDataSource(),
  );
}
