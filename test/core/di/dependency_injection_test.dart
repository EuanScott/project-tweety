import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_local.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_mock.datasource.dart';
import 'package:project_tweety/data/datasources/log_entry/logs_remote.datasource.dart';
import 'package:project_tweety/data/dtos/log_entry/log_entry.dto.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository_impl.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/fake_session_holder.dart';
import '../../support/in_memory_shared_preferences_async_platform.dart';

void main() {
  group('dependency injection', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsyncPlatform();
      await GetIt.I.reset();
    });
    tearDown(() => GetIt.I.reset());

    test('binds log entry reads to the local SQLite datasource', () async {
      await configureCoreDependencies();
      // The real holder and remote datasource reach Firebase, which has no
      // app in tests.
      expect(GetIt.I.isRegistered<LogsRemoteDataSource>(), isTrue);
      await GetIt.I.unregister<SessionHolder>();
      GetIt.I.registerSingleton<SessionHolder>(FakeSessionHolder());
      await GetIt.I.unregister<LogsRemoteDataSource>();
      GetIt.I.registerSingleton<LogsRemoteDataSource>(
        const _UnusedLogsRemoteDataSource(),
      );

      expect(GetIt.I<AppDatabase>(), isA<SqfliteAppDatabase>());
      expect(GetIt.I<LogsDataSource>(), isA<LogsLocalDataSource>());
      expect(GetIt.I<LogsRepository>(), isA<LogsRepositoryImpl>());
      expect(GetIt.I<LogEntryIdGenerator>(), isA<UuidLogEntryIdGenerator>());
      expect(GetIt.I.isRegistered<MockLogsDataSource>(), isFalse);
    });
  });
}

class const _UnusedLogsRemoteDataSource() implements LogsRemoteDataSource {
  @override
  Future<Map<String, LogEntryPushOutcome>> pushLogs(
    List<LogEntryDto> logs, {
    void Function(String logEntryId, LogEntryPushOutcome outcome)? onPushed,
  }) => throw UnimplementedError();
}
