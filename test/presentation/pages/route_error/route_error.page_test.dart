import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/core/platform/device_heading.service.dart';
import 'package:project_tweety/core/platform/device_tilt.service.dart';
import 'package:project_tweety/domain/entities/app_preferences/app_preferences.entity.dart';
import 'package:project_tweety/presentation/pages/route_error/map_scene_palette.model.dart';
import 'package:project_tweety/presentation/pages/route_error/route_error.page.dart';
import 'package:project_tweety/presentation/widgets/water_scene/scene_palette.model.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_app_preferences_repository.dart';
import '../../../support/fake_device_heading_service.dart';
import '../../../support/fake_device_tilt_service.dart';

void main() {
  useAppHarness();

  /// The page's scene moves on its own, so Reduce Motion is on unless a test
  /// is about that motion; otherwise the app never settles.
  Future<void> pumpMissingRoute(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.iOS,
    bool disableAnimations = true,
    String location = '/missing',
    List<DisplayFeature> displayFeatures = const [],
  }) async {
    await pumpApp(
      tester,
      displayFeatures: displayFeatures,
      surfaceSize: size,
      initialLocation: location,
      platform: platform,
      disableAnimations: disableAnimations,
      settle: disableAnimations,
    );
    if (!disableAnimations) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  group('RouteErrorPage', () {
    testWidgets('shows the heading, the line and Go home, with no bar above '
        'them', (tester) async {
      await pumpMissingRoute(tester);

      expect(find.byType(RouteErrorPage), findsOneWidget);
      expect(find.text('Off the edge of the map'), findsOneWidget);
      expect(find.text('Let’s point you back home.'), findsOneWidget);
      expect(find.text('Go home'), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('the heading is the page title for screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpMissingRoute(tester);

      expect(
        tester.getSemantics(find.text('Off the edge of the map')),
        isSemantics(
          isHeader: true,
          namesRoute: true,
          label: 'Off the edge of the map',
        ),
      );
      semantics.dispose();
    });

    testWidgets('hides the scene from screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpMissingRoute(tester);

      final scene = tester.getRect(find.byKey(RouteErrorPage.sceneKey));
      final labels = <String>[];
      void collect(SemanticsNode node) {
        final rect = node.transform == null
            ? node.rect
            : MatrixUtils.transformRect(node.transform!, node.rect);
        if (node.label.isNotEmpty && scene.overlaps(rect)) {
          labels.add(node.label);
        }
        node.visitChildren((SemanticsNode child) {
          collect(child);
          return true;
        });
      }

      collect(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      expect(labels, isEmpty);
      semantics.dispose();
    });

    testWidgets('goes home with the design-system primary button', (
      tester,
    ) async {
      await pumpMissingRoute(tester, platform: TargetPlatform.android);

      final button = find.widgetWithText(AppButton, 'Go home');
      expect(button, findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Go home'), findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(find.text('Home'), findsWidgets);
    });

    for (final (locale, heading) in [
      (const Locale('es'), 'Fuera del mapa'),
      (const Locale('he'), 'מעבר לקצה המפה'),
    ]) {
      testWidgets('translates the heading into ${locale.languageCode}', (
        tester,
      ) async {
        tester.platformDispatcher
          ..localeTestValue = locale
          ..localesTestValue = [locale];
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);

        await pumpMissingRoute(tester);

        expect(find.text(heading), findsOneWidget);
      });
    }
  });

  group('RouteErrorPage layouts', () {
    const heading = 'Off the edge of the map';

    for (final (name, size, platform) in [
      ('iPhone', const Size(390, 844), TargetPlatform.iOS),
      ('Android phone', const Size(412, 892), TargetPlatform.android),
      ('foldable cover screen', const Size(344, 882), TargetPlatform.android),
    ]) {
      testWidgets('$name: the phone layout, scene on top', (tester) async {
        await pumpMissingRoute(tester, size: size, platform: platform);

        expect(find.byKey(RouteErrorPage.compactLayoutKey), findsOneWidget);
        expect(find.byKey(RouteErrorPage.splitLayoutKey), findsNothing);
        final scene = tester.getRect(find.byKey(RouteErrorPage.sceneKey));
        final title = tester.getRect(find.text(heading));
        final button = tester.getRect(
          find.widgetWithText(AppButton, 'Go home'),
        );
        expect(scene.top, 0);
        expect(scene.width, size.width);
        expect(title.top, greaterThanOrEqualTo(scene.bottom));
        expect(title.center.dx, closeTo(size.width / 2, 1));
        expect(button.bottom, size.height - 40);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('phone: heading 28 px, body 16 px', (tester) async {
      await pumpMissingRoute(tester);

      final title = tester.widget<Text>(find.text(heading)).style;
      final line = tester
          .widget<Text>(find.text('Let’s point you back home.'))
          .style;
      expect(title?.fontSize, 28);
      expect(title?.fontWeight, FontWeight.w700);
      expect(line?.fontSize, 16);
    });

    testWidgets('Android phone: the button fills the width', (tester) async {
      await pumpMissingRoute(tester, platform: TargetPlatform.android);

      expect(tester.getSize(find.byType(ElevatedButton)), const Size(342, 48));
    });

    testWidgets('iPhone: the button fills the width, with its label centred', (
      tester,
    ) async {
      await pumpMissingRoute(tester);

      expect(tester.getSize(find.byType(CupertinoButton)), const Size(342, 48));
      expect(tester.getCenter(find.text('Go home')).dx, closeTo(195, 0.5));
    });

    for (final (name, size, platform, features) in [
      ('iPad', const Size(834, 1194), TargetPlatform.iOS, <DisplayFeature>[]),
      (
        'iPad landscape',
        const Size(1194, 834),
        TargetPlatform.iOS,
        <DisplayFeature>[],
      ),
      (
        'Android tablet',
        const Size(800, 1280),
        TargetPlatform.android,
        <DisplayFeature>[],
      ),
      (
        'Android tablet landscape',
        const Size(1280, 800),
        TargetPlatform.android,
        <DisplayFeature>[],
      ),
      (
        'open foldable',
        const Size(880, 1000),
        TargetPlatform.android,
        const [
          DisplayFeature(
            bounds: Rect.fromLTRB(440, 0, 440, 1000),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      ),
    ]) {
      testWidgets('$name: the split layout, scene on the left', (tester) async {
        await pumpMissingRoute(
          tester,
          size: size,
          platform: platform,
          displayFeatures: features,
        );

        expect(find.byKey(RouteErrorPage.splitLayoutKey), findsOneWidget);
        final scene = tester.getRect(find.byKey(RouteErrorPage.sceneKey));
        final title = tester.getRect(find.text(heading));
        final button = tester.getRect(
          find.widgetWithText(AppButton, 'Go home'),
        );
        expect(scene.left, 0);
        expect(scene.height, size.height);
        expect(scene.width / size.width, closeTo(0.63, 0.04));
        expect(title.left, greaterThanOrEqualTo(scene.right - 1));
        expect(button.width, lessThanOrEqualTo(400));
        expect(button.height, 48);
        expect((title.top + button.bottom) / 2, closeTo(size.height / 2, 40));
        expect(tester.widget<Text>(find.text(heading)).style?.fontSize, 32);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('right-to-left mirrors the split layout', (tester) async {
      const locale = Locale('he');
      tester.platformDispatcher
        ..localeTestValue = locale
        ..localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpMissingRoute(tester, size: const Size(1194, 834));

      final scene = tester.getRect(find.byKey(RouteErrorPage.sceneKey));
      final title = tester.getRect(find.text('מעבר לקצה המפה'));
      expect(scene.right, 1194);
      expect(title.right, lessThanOrEqualTo(scene.left + 1));
    });
  });

  group('RouteErrorPage motion', () {
    late FakeDeviceTiltService tilt;
    late FakeDeviceHeadingService heading;

    setUp(() {
      tilt = GetIt.I<DeviceTiltService>() as FakeDeviceTiltService;
      heading = GetIt.I<DeviceHeadingService>() as FakeDeviceHeadingService;
    });

    /// The needle's turn, in degrees clockwise.
    double needleDegrees(WidgetTester tester) {
      final matrix = tester
          .widget<Transform>(find.byKey(RouteErrorPage.needleKey))
          .transform;
      return math.atan2(matrix.entry(1, 0), matrix.entry(0, 0)) * 180 / math.pi;
    }

    Offset layerAt(WidgetTester tester, String layer) =>
        tester.getTopLeft(find.byKey(RouteErrorPage.layerKey(layer)));

    testWidgets('the needle turns against the heading, so it points to '
        'magnetic north', (tester) async {
      await pumpMissingRoute(tester, disableAnimations: false);

      expect(heading.isListening, isTrue);
      expect(needleDegrees(tester), closeTo(0, 0.001));

      heading.turnTo(90);
      await tester.pump();

      expect(needleDegrees(tester), closeTo(-90, 0.001));
    });

    testWidgets('only the heading turns the needle: it has no motion of its '
        'own', (tester) async {
      await pumpMissingRoute(tester, disableAnimations: false);

      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 400));

        expect(needleDegrees(tester), 0);
        expect(
          find.descendant(
            of: find.byKey(RouteErrorPage.needleKey),
            matching: find.byType(CustomPaint),
          ),
          isNot(paints..rotate()),
        );
      }
    });

    testWidgets('each map layer moves its own distance with tilt; the '
        'compass stays fixed', (tester) async {
      await pumpMissingRoute(tester, disableAnimations: false);
      final rest = {
        for (final layer in const [
          'rings',
          'farMap',
          'nearMap',
          'smallMap',
          'pin',
          'compass',
        ])
          layer: layerAt(tester, layer),
      };

      tilt.tilt(const Offset(1, 0));
      await tester.pump();

      final shifts = {
        for (final MapEntry(key: layer, value: at) in rest.entries)
          layer: layerAt(tester, layer).dx - at.dx,
      };
      expect(shifts, {
        'rings': -2,
        'farMap': -4,
        'nearMap': -7,
        'smallMap': -10,
        'pin': -12,
        'compass': 0,
      });
    });

    testWidgets('Reduce Motion keeps the compass sensors off and the needle '
        'pointing up', (tester) async {
      await pumpMissingRoute(tester);

      expect(heading.isListening, isFalse);
      expect(needleDegrees(tester), 0);
    });

    testWidgets('follows tilt and drifts on its own', (tester) async {
      await pumpMissingRoute(tester, disableAnimations: false);

      expect(tilt.isListening, isTrue);
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('Reduce Motion stops both tilt and drift', (tester) async {
      await pumpMissingRoute(tester);

      expect(tilt.isListening, isFalse);
      expect(heading.isListening, isFalse);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('stops tilt once the person goes home', (tester) async {
      await pumpMissingRoute(tester, disableAnimations: false);

      await tester.tap(find.text('Go home'));
      // Settling at all proves the drift stopped with the page.
      await tester.pumpAndSettle();

      expect(find.byType(RouteErrorPage), findsNothing);
      expect(tilt.isListening, isFalse);
      expect(heading.isListening, isFalse);
    });
  });

  group('RouteErrorPage themes', () {
    /// WCAG contrast of [foreground] laid over [background].
    double contrast(Color foreground, Color background) {
      final top = Color.alphaBlend(foreground, background).computeLuminance();
      final bottom = background.computeLuminance();
      final (light, dark) = top > bottom ? (top, bottom) : (bottom, top);
      return (light + 0.05) / (dark + 0.05);
    }

    for (final colour in AppPreferencesThemeColour.values) {
      for (final mode in [
        AppPreferencesThemeMode.light,
        AppPreferencesThemeMode.dark,
      ]) {
        testWidgets('${colour.name} ${mode.name}: its own map palette, '
            'the Sign-in sky, and readable text', (tester) async {
          replaceAppPreferencesRepository(
            FakeAppPreferencesRepository(
              AppPreferences(themeMode: mode, themeColour: colour),
            ),
          );
          await pumpMissingRoute(tester);

          final brightness = mode == .dark ? Brightness.dark : Brightness.light;
          final context = tester.element(find.byKey(RouteErrorPage.sceneKey));
          final theme = Theme.of(context);
          final page = theme.scaffoldBackgroundColor;
          final heading = tester
              .widget<Text>(find.text('Off the edge of the map'))
              .style!
              .color!;
          final line = tester
              .widget<Text>(find.text('Let’s point you back home.'))
              .style!
              .color!;

          expect(
            MapScenePalette.of(context),
            MapScenePalette.forThemeColour(colour, brightness),
          );
          expect(
            ScenePalette.of(context),
            ScenePalette.forThemeColour(colour, brightness),
          );
          expect(heading, theme.colorScheme.primary);
          expect(contrast(heading, page), greaterThanOrEqualTo(4.5));
          expect(contrast(line, page), greaterThanOrEqualTo(4.5));
          expect(
            contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
            greaterThanOrEqualTo(4.5),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
