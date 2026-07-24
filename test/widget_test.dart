import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart'
    as cards_repository;
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/domain/repositories/app_preferences/app_preferences.repository.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:project_tweety/main.dart';

import 'support/in_memory_shared_preferences_async_platform.dart';

void main() {
  const systemTextSettingsChannel = MethodChannel(
    'project_tweety/system_text_settings',
  );

  group('ProjectTweetyApp', () {
    setUp(() async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsyncPlatform();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemTextSettingsChannel, (call) async {
            if (call.method == 'openTextSettings') {
              return true;
            }

            return null;
          });
      await GetIt.I.reset();
      await configureCoreDependencies();
      await GetIt.I.unregister<cards_repository.CardsRepository>();
      GetIt.I.registerLazySingleton<cards_repository.CardsRepository>(
        () => const _FakeCardsRepository(),
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemTextSettingsChannel, null);
      await GetIt.I.reset();
    });

    testWidgets('renders app navigation tabs', (WidgetTester tester) async {
      await _pumpApp(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('redirects the root route to home', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: AppRoutes.rootPath);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('switches to cards tab', (WidgetTester tester) async {
      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(
          () => _FakeAppPreferencesRepository(
            const AppPreferences(languageCode: 'en'),
          ),
        );

      await _pumpApp(tester);

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('edits a persisted card and keeps its detail route', (
      WidgetTester tester,
    ) async {
      _replaceCardsRepository(_EditCardsRepository());

      await _pumpApp(
        tester,
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Edit card'));
      await tester.pumpAndSettle();

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      await tester.enterText(find.byType(AppTextField).first, 'Updated title');
      await tester.enterText(
        find.byType(AppTextField).last,
        'Updated description',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(
        _currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );
      expect(find.text('Updated title'), findsOneWidget);
      expect(find.text('Updated description'), findsOneWidget);
      expect(find.text('Edit card'), findsOneWidget);
    });

    testWidgets(
      'retains a missing-target edit draft and offers return to cards',
      (WidgetTester tester) async {
        _replaceCardsRepository(_EditCardsRepository(missingTarget: true));

        await _pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Edit card'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.tap(find.text('Save changes'));
        await tester.pumpAndSettle();

        expect(find.text('Card no longer exists.'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .controller
              .text,
          'Raw title',
        );
        await tester.tap(find.text('Return to cards'));
        await tester.pumpAndSettle();

        expect(_currentRoutePath(tester), AppRoutes.cardsPath);
      },
    );

    testWidgets('creates a card from the compact editor route', (
      WidgetTester tester,
    ) async {
      _replaceCardsRepository(_CreateCardsRepository());

      await _pumpApp(tester, initialLocation: '${AppRoutes.cardsPath}/new');

      expect(find.text('New card'), findsWidgets);
      expect(find.byType(AppTextField), findsNWidgets(2));

      await tester.enterText(find.byType(AppTextField).first, 'New title');
      await tester.enterText(find.byType(AppTextField).last, 'New description');
      await tester.tap(find.text('Create card'));
      await tester.pumpAndSettle();

      expect(
        _currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}created-card',
      );
      expect(find.text('New title'), findsOneWidget);
      expect(find.text('New description'), findsOneWidget);
    });

    testWidgets('renders the editor in the wide Cupertino secondary pane', (
      WidgetTester tester,
    ) async {
      _replaceCardsRepository(_CreateCardsRepository());

      await _pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: AppRoutes.cardsNewFullPath,
        platform: TargetPlatform.iOS,
      );

      expect(find.byType(CupertinoTextField), findsNWidgets(2));
      expect(find.text('New card'), findsWidgets);
    });

    testWidgets('renders the creation editor right-to-left in Hebrew', (
      WidgetTester tester,
    ) async {
      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(
          () => _FakeAppPreferencesRepository(
            const AppPreferences(languageCode: 'he'),
          ),
        );
      _replaceCardsRepository(_CreateCardsRepository());

      await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      final title = find.text('כרטיס חדש').first;
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);
      expect(find.text('צור כרטיס'), findsOneWidget);
    });

    testWidgets('opens the editor from the empty list call to action', (
      WidgetTester tester,
    ) async {
      _replaceCardsRepository(_CreateCardsRepository());

      await _pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      expect(find.text('No cards yet'), findsOneWidget);
      await tester.tap(find.text('Create card'));
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsNewFullPath);
    });

    testWidgets('opens the editor from the Cards toolbar action', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: AppRoutes.cardsPath);

      await tester.tap(find.byTooltip('Create card'));
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsNewFullPath);
    });

    testWidgets('keeps a dirty create draft when discard is dismissed', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsNewFullPath);
      expect(
        tester
            .widget<AppTextField>(find.byType(AppTextField).first)
            .controller
            .text,
        'Raw title',
      );
    });

    testWidgets('discards a dirty create draft after confirmation', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('guards and de-duplicates dirty active-tab resets', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.enterText(find.byType(AppTextField).first, 'Raw title');
      await tester.tap(find.text('Cards'));
      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsPath);
    });

    testWidgets('shows and updates validation errors after create submission', (
      WidgetTester tester,
    ) async {
      _replaceCardsRepository(_CreateCardsRepository());

      await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

      await tester.tap(find.text('Create card'));
      await tester.pump();

      expect(find.text('Enter a title.'), findsOneWidget);
      expect(find.text('Enter a description.'), findsOneWidget);

      await tester.enterText(find.byType(AppTextField).first, 'Title');
      await tester.pump();

      expect(find.text('Enter a title.'), findsNothing);
      expect(find.text('Enter a description.'), findsOneWidget);
    });

    testWidgets(
      'retains editor input and inline feedback when creation fails',
      (WidgetTester tester) async {
        _replaceCardsRepository(
          _CreateCardsRepository(error: StateError('write failed')),
        );

        await _pumpApp(tester, initialLocation: AppRoutes.cardsNewFullPath);

        await tester.enterText(find.byType(AppTextField).first, 'Raw title');
        await tester.enterText(
          find.byType(AppTextField).last,
          'Raw description',
        );
        await tester.tap(find.text('Create card'));
        await tester.pumpAndSettle();

        expect(find.text('Unable to save card. Try again.'), findsOneWidget);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .controller
              .text,
          'Raw title',
        );
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).last)
              .controller
              .text,
          'Raw description',
        );
      },
    );

    testWidgets('opens card details from the cards list on compact width', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, surfaceSize: const Size(400, 800));

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        _currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsNothing);
      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets(
      'dismissing compact Material delete confirmation leaves the card unchanged',
      (WidgetTester tester) async {
        final repository = _DeleteCardsRepository();
        _replaceCardsRepository(repository);

        await _pumpApp(
          tester,
          surfaceSize: const Size(400, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete card'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Keep card'));
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 0);
        expect(find.text('Card Title 1'), findsOneWidget);
        expect(
          _currentRoutePath(tester),
          '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );
      },
    );

    testWidgets(
      'confirms wide Cupertino deletion and returns to the cards root',
      (WidgetTester tester) async {
        final repository = _DeleteCardsRepository();
        _replaceCardsRepository(repository);

        await _pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        await tester.tap(find.text('Delete card'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);

        await tester.tap(find.text('Delete card').last);
        await tester.pumpAndSettle();

        expect(repository.deleteRequestCount, 1);
        expect(_currentRoutePath(tester), AppRoutes.cardsPath);
        expect(find.text('Card Title 1'), findsNothing);
      },
    );

    testWidgets(
      'keeps RTL details visible and offers deletion retry on failure',
      (WidgetTester tester) async {
        GetIt.I
          ..unregister<AppPreferencesRepository>()
          ..registerLazySingleton<AppPreferencesRepository>(
            () => _FakeAppPreferencesRepository(
              const AppPreferences(languageCode: 'he'),
            ),
          );
        final repository = _DeleteCardsRepository(error: StateError('failed'));
        _replaceCardsRepository(repository);

        await _pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        final deleteAction = find.text('מחק כרטיס');
        expect(
          Directionality.of(tester.element(deleteAction)),
          TextDirection.rtl,
        );
        await tester.tap(deleteAction);
        await tester.pumpAndSettle();
        await tester.tap(find.text('מחק כרטיס').last);
        await tester.pumpAndSettle();

        expect(find.text('לא ניתן למחוק את הכרטיס. נסה שוב.'), findsOneWidget);
        expect(find.text('נסה למחוק שוב'), findsOneWidget);
        expect(find.text('Card Title 1'), findsOneWidget);

        await tester.tap(find.text('נסה למחוק שוב'));
        await tester.pumpAndSettle();
        expect(repository.deleteRequestCount, 2);
      },
    );

    testWidgets('keeps compact iOS card details below the app bar', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
      );

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      final navigationBarBottom = tester
          .getRect(find.byType(CupertinoNavigationBar))
          .bottom;
      final detailsTitleTop = tester
          .getRect(find.text('Card Title 1').last)
          .top;

      expect(detailsTitleTop, greaterThanOrEqualTo(navigationBarBottom));
    });

    testWidgets('keeps wide iOS selected card details below the app bar', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
      );

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      final detailsTitleTop = tester
          .getRect(find.text('Card Title 1').last)
          .top;

      expect(
        detailsTitleTop,
        greaterThanOrEqualTo(kMinInteractiveDimensionCupertino),
      );
    });

    testWidgets('opens card details from a direct compact route', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(400, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.text('Card details'), findsOneWidget);
      expect(find.text('Card Title 1'), findsOneWidget);
      expect(find.text('card-1'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('shows cards list and details together on wide card route', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Card Title 1'), findsWidgets);
      expect(find.text('card-1'), findsOneWidget);
    });

    testWidgets(
      'loads a direct detail route once from the shared cards collection',
      (WidgetTester tester) async {
        final cards = Completer<List<cards_repository.Card>>();
        final repository = _ControlledCardsRepository(() => cards.future);
        _replaceCardsRepository(repository);

        await _pumpApp(
          tester,
          surfaceSize: const Size(900, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
          settle: false,
        );

        expect(find.byType(AppLoadingIndicator), findsWidgets);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);

        cards.complete([_FakeCardsRepository._cards.first]);
        await tester.pumpAndSettle();

        expect(find.text('card-1'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets('shows a missing detail for an unknown direct card route', (
      WidgetTester tester,
    ) async {
      final repository = _ControlledCardsRepository(() async => const []);
      _replaceCardsRepository(repository);

      await _pumpApp(
        tester,
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}missing-card',
      );

      expect(find.text('Card not found'), findsOneWidget);
      expect(find.text('This card is not available.'), findsOneWidget);
      expect(repository.collectionReadCount, 1);
      expect(repository.detailReadCount, 0);
    });

    testWidgets(
      'shows a detail failure when the shared collection load fails',
      (WidgetTester tester) async {
        final repository = _ControlledCardsRepository(
          () async => throw StateError('collection failed'),
        );
        _replaceCardsRepository(repository);

        await _pumpApp(
          tester,
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
        );

        expect(find.text('Unable to load card'), findsOneWidget);
        expect(repository.collectionReadCount, 1);
        expect(repository.detailReadCount, 0);
      },
    );

    testWidgets('scrolls selected card into view on wide direct card route', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
      );

      final cardsList = tester.widget<ListView>(
        find.byWidgetPredicate(
          (widget) => widget is ListView && widget.controller != null,
        ),
      );

      expect(cardsList.controller!.offset, greaterThan(0));
      expect(find.text('Card Title 10'), findsNWidgets(2));
      expect(find.text('card-10'), findsOneWidget);
    });

    testWidgets(
      'scrolling card details does not scroll cards list on wide iOS layout',
      (WidgetTester tester) async {
        await _pumpApp(
          tester,
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(1000, 800),
          initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
        );

        final cardsList = tester.widget<ListView>(
          find.byWidgetPredicate(
            (widget) => widget is ListView && widget.controller != null,
          ),
        );
        final initialOffset = cardsList.controller!.offset;

        expect(initialOffset, greaterThan(0));

        await tester.drag(find.text('card-10'), const Offset(0, 300));
        await tester.pumpAndSettle();

        expect(cardsList.controller!.offset, initialOffset);

        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(find.text('card-10')),
            scrollDelta: const Offset(0, 300),
          ),
        );
        await tester.pumpAndSettle();

        expect(cardsList.controller!.offset, initialOffset);
      },
    );

    testWidgets('wide iOS cards disable page-level sliver scrolling', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1000, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-10',
      );

      final nestedScrollView = tester.widget<NestedScrollView>(
        find.byType(NestedScrollView),
      );

      expect(nestedScrollView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('selects a card through the wide detail route', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, surfaceSize: const Size(900, 800));

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      expect(find.text('Select a card'), findsOneWidget);

      await tester.tap(find.text('Card Title 1'));
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsNothing);
      expect(find.text('card-1'), findsOneWidget);
      expect(
        _currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsNothing);
      expect(find.text('Select a card'), findsOneWidget);
    });

    testWidgets('replaces the wide card detail route on later selection', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.text('Card Title 2').first);
      await tester.pumpAndSettle();

      expect(
        _currentRoutePath(tester),
        '${AppRoutes.cardsDetailFullPathPrefix}card-2',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(_currentRoutePath(tester), AppRoutes.cardsPath);
      expect(find.text('card-1'), findsNothing);
      expect(find.text('card-2'), findsNothing);
    });

    testWidgets('active cards tab returns wide direct details route to root', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(900, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      expect(find.text('card-1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('card-1'), findsNothing);
      expect(find.text('Select a card'), findsOneWidget);
    });

    testWidgets('tapping active cards tab returns card details to cards root', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        surfaceSize: const Size(400, 800),
        initialLocation: '${AppRoutes.cardsDetailFullPathPrefix}card-1',
      );

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Card details'), findsNothing);
      expect(find.text('card-1'), findsNothing);
      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets('app follows the system locale when no language is stored', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('es');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      tester.platformDispatcher.localesTestValue = const <Locale>[Locale('es')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(
          () => _FakeAppPreferencesRepository(const AppPreferences()),
        );

      await _pumpApp(tester);

      expect(find.text('Inicio'), findsWidgets);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        isNull,
      );
    });

    testWidgets('selecting Hebrew updates locale and directionality', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAppPreferencesRepository(
        const AppPreferences(languageCode: 'en'),
      );

      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(() => repository);

      await _pumpApp(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();

      await tester.tap(_languageDropdownFinder());
      await tester.pumpAndSettle();
      await tester.tap(find.text('עברית').last);
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('he'),
      );
      expect(
        Directionality.of(tester.element(find.text('תצוגה ושפה'))),
        TextDirection.rtl,
      );
      expect(repository.savedPreferences.last.languageCode, 'he');
    });

    testWidgets(
      'selecting system default clears the stored language override',
      (WidgetTester tester) async {
        final repository = _FakeAppPreferencesRepository(
          const AppPreferences(languageCode: 'en'),
        );

        GetIt.I
          ..unregister<AppPreferencesRepository>()
          ..registerLazySingleton<AppPreferencesRepository>(() => repository);

        await _pumpApp(tester);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Display and language'));
        await tester.pumpAndSettle();

        await tester.tap(_languageDropdownFinder());
        await tester.pumpAndSettle();
        await tester.tap(find.text('System default').last);
        await tester.pumpAndSettle();

        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
          isNull,
        );
        expect(repository.savedPreferences.last.languageCode, isNull);
      },
    );

    testWidgets('switching language updates tab and settings labels', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAppPreferencesRepository(
        const AppPreferences(languageCode: 'en'),
      );

      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(() => repository);

      await _pumpApp(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();

      await tester.tap(_languageDropdownFinder());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español').last);
      await tester.pumpAndSettle();

      expect(find.text('Tema'), findsOneWidget);
      expect(find.text('Pantalla e idioma'), findsOneWidget);
    });

    testWidgets('supports large text scaling without overflow on key screens', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpApp(tester);

      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();

      expect(find.text('Display and language'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens system text settings from app preferences', (
      WidgetTester tester,
    ) async {
      var methodCallCount = 0;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(systemTextSettingsChannel, (call) async {
            if (call.method == 'openTextSettings') {
              methodCallCount += 1;
              return true;
            }

            return null;
          });

      await _pumpApp(tester);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display and language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(methodCallCount, 1);
    });

    testWidgets('keeps bottom navigation visible on app preferences', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await _openAppPreferences(tester);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows the device theme setting when theme is overridden', (
      WidgetTester tester,
    ) async {
      GetIt.I
        ..unregister<AppPreferencesRepository>()
        ..registerLazySingleton<AppPreferencesRepository>(
          () => _FakeAppPreferencesRepository(
            const AppPreferences(themeMode: AppPreferencesThemeMode.light),
          ),
        );

      await _pumpApp(
        tester,
        platformBrightness: Brightness.dark,
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      );

      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Device setting: Dark'), findsOneWidget);
    });

    testWidgets('opens app preferences from a direct route', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      );

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      expect(navigationBar.selectedIndex, 2);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('explains denied settings deep links', (
      WidgetTester tester,
    ) async {
      await _pumpApp(
        tester,
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
        canAccessSettings: false,
      );

      expect(find.text('Theme'), findsNothing);
      expect(find.text('Access denied'), findsWidgets);
      expect(find.text('You do not have access to this page.'), findsOneWidget);
    });

    testWidgets('shows a navigation error page for unknown routes', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: '/missing');

      expect(find.text('Page not found'), findsWidgets);
      expect(
        find.text('The page you were looking for is not available.'),
        findsOneWidget,
      );
      expect(find.text('Go home'), findsOneWidget);
    });

    testWidgets('navigates home from the navigation error page', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, initialLocation: '/missing');

      await tester.tap(find.text('Go home'));
      await tester.pumpAndSettle();

      expect(find.text('Page not found'), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('tapping active settings tab returns nested route to root', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await _openAppPreferences(tester);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsNothing);
      expect(find.text('Display and language'), findsOneWidget);
    });

    testWidgets('tapping active cards tab scrolls cards list to the top', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester, surfaceSize: const Size(400, 600));

      await tester.tap(find.text('Cards'));
      await tester.pumpAndSettle();

      final cardsList = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.controller != null,
      );

      await tester.drag(cardsList, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsNothing);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Card Title 1'), findsOneWidget);
    });

    testWidgets(
      'iOS cards use large title scroll coordination without refresh action',
      (WidgetTester tester) async {
        await _pumpApp(tester, platform: TargetPlatform.iOS);

        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsNothing);

        final cardsList = find.byType(ListView).first;
        final listView = tester.widget<ListView>(cardsList);
        expect(listView.controller, isNotNull);
      },
    );

    testWidgets(
      'tapping active cards rail item scrolls cards list to the top',
      (WidgetTester tester) async {
        await _pumpApp(tester, surfaceSize: const Size(900, 800));

        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();

        final cardsList = find.byWidgetPredicate(
          (widget) => widget is ListView && widget.controller != null,
        );

        await tester.drag(cardsList, const Offset(0, -900));
        await tester.pumpAndSettle();

        expect(find.text('Card Title 1'), findsNothing);

        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Card Title 1'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping active cards rail item resets a selected cards route',
      (WidgetTester tester) async {
        await _pumpApp(tester, surfaceSize: const Size(900, 800));

        await tester.tap(find.text('Cards'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Card Title 1'));
        await tester.pumpAndSettle();

        final cardsList = find.byWidgetPredicate(
          (widget) => widget is ListView && widget.controller != null,
        );

        await tester.drag(cardsList, const Offset(0, -900));
        await tester.pumpAndSettle();

        expect(
          tester.widget<ListView>(cardsList).controller!.offset,
          greaterThan(0),
        );
        expect(find.text('card-1'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.grid_view_rounded));
        await tester.pumpAndSettle();

        final resetCardsList = tester.widget<ListView>(
          find.byWidgetPredicate(
            (widget) => widget is ListView && widget.controller != null,
          ),
        );

        expect(find.text('Card Title 1'), findsWidgets);
        expect(resetCardsList.controller!.offset, 0);
        expect(find.text('card-1'), findsNothing);
      },
    );
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Size surfaceSize = const Size(400, 800),
  String? initialLocation,
  bool canAccessSettings = true,
  Brightness platformBrightness = Brightness.light,
  TargetPlatform? platform,
  bool settle = true,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(platformBrightness: platformBrightness),
      child: MyApp(
        initialLocation: initialLocation,
        platform: platform,
        canAccessSettings: canAccessSettings,
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _openAppPreferences(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Display and language'));
  await tester.pumpAndSettle();
}

Finder _languageDropdownFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<String?>,
  );
}

String _currentRoutePath(WidgetTester tester) {
  final routeOwner = find.byType(NavigationRail).evaluate().isNotEmpty
      ? find.byType(NavigationRail)
      : find.byType(NavigationBar).evaluate().isNotEmpty
      ? find.byType(NavigationBar)
      : find.byType(Navigator).first;
  final context = tester.element(routeOwner);

  return GoRouter.of(context).state.uri.path;
}

class _FakeAppPreferencesRepository implements AppPreferencesRepository {
  _FakeAppPreferencesRepository(this._currentPreferences);

  AppPreferences _currentPreferences;
  final List<AppPreferences> savedPreferences = <AppPreferences>[];

  @override
  Future<AppPreferences> getAppPreferences() async {
    return _currentPreferences;
  }

  @override
  Future<void> saveAppPreferences(AppPreferences appPreferences) async {
    _currentPreferences = appPreferences;
    savedPreferences.add(appPreferences);
  }
}

void _replaceCardsRepository(cards_repository.CardsRepository repository) {
  GetIt.I
    ..unregister<cards_repository.CardsRepository>()
    ..registerLazySingleton<cards_repository.CardsRepository>(() => repository);
}

class _ControlledCardsRepository implements cards_repository.CardsRepository {
  _ControlledCardsRepository(this._loadCards);

  final Future<List<cards_repository.Card>> Function() _loadCards;
  var collectionReadCount = 0;
  var detailReadCount = 0;

  @override
  Future<List<cards_repository.Card>> getCards() {
    collectionReadCount += 1;
    return _loadCards();
  }

  @override
  Future<cards_repository.Card?> getCardById(String cardId) {
    detailReadCount += 1;
    throw UnsupportedError('Details must derive from the loaded collection.');
  }

  @override
  Future<cards_repository.Card> createCard(cards_repository.CardDraft draft) {
    throw UnsupportedError('Card creation is not configured.');
  }

  @override
  Future<cards_repository.Card> updateCard({
    required String cardId,
    required cards_repository.CardDraft draft,
  }) {
    throw UnsupportedError('Card updates are not configured.');
  }

  @override
  Future<void> deleteCard(String cardId) async {}
}

class _FakeCardsRepository implements cards_repository.CardsRepository {
  const _FakeCardsRepository();

  @override
  Future<List<cards_repository.Card>> getCards() async => _cards;

  @override
  Future<cards_repository.Card?> getCardById(String cardId) async {
    for (final card in _cards) {
      if (card.id == cardId) {
        return card;
      }
    }

    return null;
  }

  @override
  Future<cards_repository.Card> createCard(
    cards_repository.CardDraft draft,
  ) async {
    return cards_repository.Card(
      id: 'created-card',
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
  }

  @override
  Future<cards_repository.Card> updateCard({
    required String cardId,
    required cards_repository.CardDraft draft,
  }) async {
    return cards_repository.Card(
      id: cardId,
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
  }

  @override
  Future<void> deleteCard(String cardId) async {}

  static final _cards = List<cards_repository.Card>.generate(
    10,
    (index) => cards_repository.Card(
      id: 'card-${index + 1}',
      title: 'Card Title ${index + 1}',
      description:
          'This is the body copy for card number ${index + 1}. '
          'You can replace this with whatever description you want.',
    ),
    growable: false,
  );
}

class _CreateCardsRepository implements cards_repository.CardsRepository {
  _CreateCardsRepository({this.error});

  final Object? error;
  final List<cards_repository.Card> _cards = [];

  @override
  Future<cards_repository.Card> createCard(
    cards_repository.CardDraft draft,
  ) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    final card = cards_repository.Card(
      id: 'created-card',
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
    _cards.add(card);
    return card;
  }

  @override
  Future<void> deleteCard(String cardId) async {}

  @override
  Future<cards_repository.Card?> getCardById(String cardId) async {
    for (final card in _cards) {
      if (card.id == cardId) {
        return card;
      }
    }
    return null;
  }

  @override
  Future<List<cards_repository.Card>> getCards() async => _cards;

  @override
  Future<cards_repository.Card> updateCard({
    required String cardId,
    required cards_repository.CardDraft draft,
  }) {
    throw UnsupportedError('Card updates are not configured.');
  }
}

class _EditCardsRepository extends _FakeCardsRepository {
  _EditCardsRepository({this.missingTarget = false});

  final bool missingTarget;

  @override
  Future<cards_repository.Card> updateCard({
    required String cardId,
    required cards_repository.CardDraft draft,
  }) async {
    if (missingTarget) {
      throw cards_repository.CardNotFoundException(cardId);
    }
    return cards_repository.Card(
      id: cardId,
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
  }
}

class _DeleteCardsRepository implements cards_repository.CardsRepository {
  _DeleteCardsRepository({this.error})
    : _cards = List<cards_repository.Card>.of(_FakeCardsRepository._cards);

  final Object? error;
  final List<cards_repository.Card> _cards;
  var deleteRequestCount = 0;

  @override
  Future<cards_repository.Card> createCard(cards_repository.CardDraft draft) {
    throw UnsupportedError('Card creation is not configured.');
  }

  @override
  Future<void> deleteCard(String cardId) async {
    deleteRequestCount++;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    _cards.removeWhere((card) => card.id == cardId);
  }

  @override
  Future<cards_repository.Card?> getCardById(String cardId) async {
    for (final card in _cards) {
      if (card.id == cardId) {
        return card;
      }
    }
    return null;
  }

  @override
  Future<List<cards_repository.Card>> getCards() async => _cards;

  @override
  Future<cards_repository.Card> updateCard({
    required String cardId,
    required cards_repository.CardDraft draft,
  }) {
    throw UnsupportedError('Card updates are not configured.');
  }
}
