import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';

const _intro =
    'Change the appearance, theme colour, language and text of the app.';
const _fjordDescription =
    "Teal water and plum dusk from Norway's deep sea inlets. Calm and clear, "
    'like a still morning on the water.';
const _kalahariDescription =
    'Red ochre dunes under a wide blue desert sky. Warm and earthy, from the '
    'great sands of southern Africa.';

Future<FakeAppPreferencesRepository> _pumpPreferences(
  WidgetTester tester, {
  AppPreferences preferences = const AppPreferences(),
  TargetPlatform? platform,
  Size surfaceSize = const Size(400, 800),
}) async {
  final repository = FakeAppPreferencesRepository(preferences);
  replaceAppPreferencesRepository(repository);

  await pumpApp(
    tester,
    platform: platform,
    surfaceSize: surfaceSize,
    initialLocation: AppRoutes.settingsAppPreferencesFullPath,
  );

  return repository;
}

void main() {
  group('App preferences', () {
    useAppHarness();

    testWidgets('supports large text scaling without overflow on key screens', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester);

      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Personalisation'));
      await tester.pumpAndSettle();

      expect(find.text('Personalisation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (platform, headers) in [
      (
        TargetPlatform.android,
        ['Appearance', 'Language', 'Text and display'],
      ),
      (TargetPlatform.iOS, ['APPEARANCE', 'LANGUAGE', 'TEXT AND DISPLAY']),
    ]) {
      testWidgets('shows the three sections in order on ${platform.name}', (
        tester,
      ) async {
        await _pumpPreferences(tester, platform: platform);

        final tops = [
          for (final header in headers)
            tester.getTopLeft(find.text(header).first).dy,
        ];

        expect(find.byType(AppListSection), findsNWidgets(3));
        expect(tops, orderedEquals([...tops]..sort()));
      });
    }

    testWidgets('applies a Theme segment at once', (tester) async {
      final repository = await _pumpPreferences(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(
        repository.savedPreferences.last.themeMode,
        AppPreferencesThemeMode.dark,
      );
      expect(
        Theme.of(tester.element(find.text('Dark'))).brightness,
        Brightness.dark,
      );
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('titles the page Personalisation and shows the intro above '
          'Appearance on ${platform.name}', (tester) async {
        await _pumpPreferences(tester, platform: platform);

        final appearance = platform == TargetPlatform.iOS
            ? 'APPEARANCE'
            : 'Appearance';

        expect(find.text('Personalisation'), findsOneWidget);
        expect(find.text(_intro), findsOneWidget);
        expect(
          tester.getBottomLeft(find.text(_intro)).dy,
          lessThan(tester.getTopLeft(find.text(appearance)).dy),
        );
      });
    }

    testWidgets('shows all seven theme colours with Fjord selected', (
      tester,
    ) async {
      await _pumpPreferences(tester);

      final picker = tester.widget<AppSwatchPicker<AppPreferencesThemeColour>>(
        find.byType(AppSwatchPicker<AppPreferencesThemeColour>),
      );

      expect(picker.options.map((option) => option.value), [
        ...AppPreferencesThemeColour.values,
      ]);
      expect(picker.value, AppPreferencesThemeColour.fjord);
      expect(find.text('Theme colour'), findsOneWidget);
      expect(find.textContaining(' · '), findsNothing);
      expect(find.textContaining('Teal with plum'), findsNothing);
      expect(find.text(_fjordDescription), findsOneWidget);
    });

    testWidgets('applies a theme colour at once and describes it', (
      tester,
    ) async {
      final repository = await _pumpPreferences(tester);

      await tester.ensureVisible(find.text('Kalahari'));
      await tester.tap(find.text('Kalahari'));
      await tester.pumpAndSettle();

      expect(
        repository.savedPreferences.last.themeColour,
        AppPreferencesThemeColour.kalahari,
      );
      expect(
        Theme.of(tester.element(find.text('Kalahari'))).colorScheme.primary,
        const Color(0xFFA8441F),
      );
      expect(find.text(_kalahariDescription), findsOneWidget);
      expect(find.text(_fjordDescription), findsNothing);
    });

    testWidgets('marks the theme description as a live region', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpPreferences(tester);

      expect(
        tester.getSemantics(find.text(_fjordDescription)),
        matchesSemantics(label: _fjordDescription, isLiveRegion: true),
      );
      semantics.dispose();
    });

    testWidgets('chooses a language from a radio dialog on Android', (
      tester,
    ) async {
      final repository = await _pumpPreferences(tester);

      expect(find.text('System default'), findsOneWidget);
      expect(
        find.text(
          'Following device setting: English. '
          'Text direction follows the language.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(AppSelectionRow<String?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(repository.savedPreferences.last.languageCode, 'es');
      expect(find.text('Apariencia'), findsOneWidget);
    });

    testWidgets('chooses a language from a pushed list on iOS', (
      tester,
    ) async {
      final repository = await _pumpPreferences(
        tester,
        platform: TargetPlatform.iOS,
      );

      await tester.tap(find.byType(AppSelectionRow<String?>));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(repository.savedPreferences.last.languageCode, 'en');
      expect(find.byType(AppSelectionRow<String?>), findsOneWidget);
      expect(find.text('Text direction follows the language.'), findsOneWidget);
    });

    testWidgets('flips the language row in Hebrew on iOS', (tester) async {
      await _pumpPreferences(
        tester,
        platform: TargetPlatform.iOS,
        preferences: const AppPreferences(languageCode: 'he'),
      );

      final row = find.byType(AppSelectionRow<String?>);
      final titleX = tester
          .getCenter(find.descendant(of: row, matching: find.text('שפה')))
          .dx;
      final valueX = tester
          .getCenter(find.descendant(of: row, matching: find.text('עברית')))
          .dx;

      expect(valueX, lessThan(titleX));
    });

    testWidgets('opens the system text settings from the link row', (
      tester,
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

      await _pumpPreferences(tester);
      await tester.ensureVisible(find.text('Text size and bold text'));
      await tester.tap(find.text('Text size and bold text'));
      await tester.pumpAndSettle();

      expect(methodCallCount, 1);
      expect(find.byType(SnackBar), findsNothing);
      expect(
        find.text('Change font size and bold text in your device settings.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a snack bar when the system text settings fail', (
      tester,
    ) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            systemTextSettingsChannel,
            (call) async => false,
          );

      await _pumpPreferences(tester);
      await tester.ensureVisible(find.text('Text size and bold text'));
      await tester.tap(find.text('Text size and bold text'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unable to open settings on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('has no layout direction row or open settings button', (
      tester,
    ) async {
      await _pumpPreferences(tester);

      expect(find.text('Layout direction'), findsNothing);
      expect(find.text('Open settings'), findsNothing);
      expect(find.byType(AppButton), findsNothing);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('centres the content in a 600 px column on a wide window '
          'on ${platform.name}', (tester) async {
        await _pumpPreferences(
          tester,
          platform: platform,
          surfaceSize: const Size(1200, 900),
        );

        final sections = find.byType(AppListSection);
        final rect = tester.getRect(sections.first);
        final page = tester.getRect(
          find.ancestor(of: sections.first, matching: find.byType(Scrollable)),
        );
        final picker = find.byType(AppSwatchPicker<AppPreferencesThemeColour>);

        expect(rect.width, 600);
        expect(rect.center.dx, moreOrLessEquals(page.center.dx, epsilon: 0.5));
        expect(
          find.descendant(of: picker, matching: find.byType(Scrollable)),
          findsNothing,
        );
      });
    }

    testWidgets('fills the width on a phone', (tester) async {
      await _pumpPreferences(tester);

      expect(tester.getRect(find.byType(AppListSection).first).width, 400);
    });

    testWidgets('keeps bottom navigation visible on app preferences', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      await openAppPreferences(tester);

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('opens app preferences from a direct route', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        initialLocation: AppRoutes.settingsAppPreferencesFullPath,
      );

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );

      expect(navigationBar.selectedIndex, 2);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
