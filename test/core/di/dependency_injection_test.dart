import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/core/storage/app_database.storage.dart';
import 'package:project_tweety/data/datasources/card/cards.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_local.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_mock.datasource.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/data/repositories/card/cards.repository_impl.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    test('binds card reads to the local SQLite datasource', () async {
      await configureCoreDependencies();

      expect(GetIt.I<AppDatabase>(), isA<SqfliteAppDatabase>());
      expect(GetIt.I<CardsDataSource>(), isA<CardsLocalDataSource>());
      expect(GetIt.I<CardsRepository>(), isA<CardsRepositoryImpl>());
      expect(GetIt.I<CardIdGenerator>(), isA<UuidCardIdGenerator>());
      expect(GetIt.I.isRegistered<MockCardsDataSource>(), isFalse);
    });
  });
}
