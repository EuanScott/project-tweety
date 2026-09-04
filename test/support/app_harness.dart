import 'dart:ui' show DisplayFeature;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';
import 'package:project_tweety/main.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_cards_repository.dart';
import 'in_memory_shared_preferences_async_platform.dart';

const systemTextSettingsChannel = MethodChannel(
  'project_tweety/system_text_settings',
);

/// Registers the `setUp`/`tearDown` pair every whole-app widget test needs.
///
/// Installs in-memory shared preferences, stubs the system text settings
/// channel, builds a real DI container, and swaps in a working
/// [FakeCardsRepository] so tests that do not care about cards still render.
///
/// Call once at the top of a `group`.
void useAppHarness() {
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
    await GetIt.I.unregister<CardsRepository>();
    GetIt.I.registerLazySingleton<CardsRepository>(FakeCardsRepository.new);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(systemTextSettingsChannel, null);
    await GetIt.I.reset();
  });
}

/// Pumps the whole app at [surfaceSize].
///
/// [padding] and [displayFeatures] describe the device the app is running on:
/// safe-area insets and any fold or hinge. Both reach layout code that
/// classifies the surface, so adaptive behaviour can be driven from here rather
/// than only at the widget level.
Future<void> pumpApp(
  WidgetTester tester, {
  Size surfaceSize = const Size(400, 800),
  String? initialLocation,
  bool canAccessSettings = true,
  Brightness platformBrightness = Brightness.light,
  EdgeInsets padding = EdgeInsets.zero,
  List<DisplayFeature> displayFeatures = const [],
  TargetPlatform? platform,
  bool settle = true,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: surfaceSize,
        platformBrightness: platformBrightness,
        padding: padding,
        displayFeatures: displayFeatures,
      ),
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

Future<void> openAppPreferences(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Display and language'));
  await tester.pumpAndSettle();
}

Finder languageDropdownFinder() {
  return find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<String?>,
  );
}

String currentRoutePath(WidgetTester tester) {
  final routeOwner = find.byType(NavigationRail).evaluate().isNotEmpty
      ? find.byType(NavigationRail)
      : find.byType(NavigationBar).evaluate().isNotEmpty
      ? find.byType(NavigationBar)
      : find.byType(Navigator).first;
  final context = tester.element(routeOwner);

  return GoRouter.of(context).state.uri.path;
}
