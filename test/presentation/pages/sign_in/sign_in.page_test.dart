import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/core/platform/device_tilt.service.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';
import 'package:project_tweety/presentation/pages/sign_in/sign_in.page.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_auth_repository.dart';
import '../../../support/fake_device_tilt_service.dart';

void main() {
  useAppHarness();

  late FakeAuthRepository repository;
  late FakeDeviceTiltService tilt;

  setUp(() {
    repository = FakeAuthRepository(session: const Session.signedOut());
    replaceAuthRepository(repository);
    tilt = GetIt.I<DeviceTiltService>() as FakeDeviceTiltService;
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    Locale? locale,
    Brightness brightness = Brightness.light,
    bool disableAnimations = false,
    List<DisplayFeature> displayFeatures = const [],
  }) async {
    if (locale != null) {
      tester.platformDispatcher
        ..localeTestValue = locale
        ..localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }

    await pumpApp(
      tester,
      surfaceSize: size,
      platformBrightness: brightness,
      disableAnimations: disableAnimations,
      displayFeatures: displayFeatures,
    );
  }

  Future<void> pressSignIn(WidgetTester tester) async {
    await tester.tap(find.byType(AppGoogleSignInButton));
    await tester.pump();
  }

  AppGoogleSignInButton button(WidgetTester tester) =>
      tester.widget<AppGoogleSignInButton>(find.byType(AppGoogleSignInButton));

  group('SignInPage states', () {
    testWidgets('ready: shows the copy and an enabled button', (tester) async {
      await pumpPage(tester);

      expect(find.text('Project Tweety'), findsOneWidget);
      expect(
        find.text('Sign in to keep your Cards and back them up.'),
        findsOneWidget,
      );
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(
        find.text('Your Cards stay on this device until you sync them.'),
        findsOneWidget,
      );
      expect(find.text("Sign-in didn't work"), findsNothing);
      expect(button(tester).onPressed, isNotNull);
      expect(button(tester).loading, isFalse);
    });

    testWidgets('signing in: the button is loading and disabled', (
      tester,
    ) async {
      repository.pendingSignIn = Completer<void>();
      await pumpPage(tester);

      await pressSignIn(tester);

      expect(button(tester).loading, isTrue);
      expect(find.text('Signing in…'), findsOneWidget);
      await tester.tap(find.byType(AppGoogleSignInButton));
      expect(repository.signInRequestCount, 1);

      repository.pendingSignIn!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsNothing);
    });

    testWidgets('network failure: shows the network copy above the button', (
      tester,
    ) async {
      repository.signInResult = const SignInResult.failed(
        SignInFailure.network,
      );
      await pumpPage(tester);

      await pressSignIn(tester);

      expect(find.text("Sign-in didn't work"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expect(button(tester).loading, isFalse);
      expect(button(tester).onPressed, isNotNull);
    });

    testWidgets('other failure: shows the general copy', (tester) async {
      repository.signInResult = const SignInResult.failed(SignInFailure.other);
      await pumpPage(tester);

      await pressSignIn(tester);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('pressing the button again after a failure retries', (
      tester,
    ) async {
      repository.signInResult = const SignInResult.failed(SignInFailure.other);
      await pumpPage(tester);
      await pressSignIn(tester);

      repository.signInResult = const SignInResult.cancelled();
      await pressSignIn(tester);

      expect(repository.signInRequestCount, 2);
      expect(find.text("Sign-in didn't work"), findsNothing);
      expect(find.byType(AppGoogleSignInButton), findsOneWidget);
    });

    testWidgets('announces the failure to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      repository.signInResult = const SignInResult.failed(SignInFailure.other);
      await pumpPage(tester);

      await pressSignIn(tester);

      expect(
        tester.getSemantics(find.byKey(SignInPage.errorKey)),
        isSemantics(isLiveRegion: true),
      );
      semantics.dispose();
    });
  });

  group('SignInPage layouts', () {
    testWidgets('a phone width uses the compact layout', (tester) async {
      await pumpPage(tester);

      expect(find.byKey(SignInPage.compactLayoutKey), findsOneWidget);
      expect(find.byKey(SignInPage.splitLayoutKey), findsNothing);
    });

    testWidgets('a tablet width uses the split layout', (tester) async {
      await pumpPage(tester, size: const Size(1194, 834));

      expect(find.byKey(SignInPage.splitLayoutKey), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Use your Google Account to continue.'), findsOneWidget);
      expect(
        find.text('Your Cards, on this device and backed up when you choose.'),
        findsOneWidget,
      );
    });

    testWidgets('a vertical fold splits the panes on the hinge', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(882, 800),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(430, 0, 450, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );

      expect(find.byKey(SignInPage.splitLayoutKey), findsOneWidget);
      expect(tester.getRect(find.byKey(SignInPage.scenePaneKey)).left, 0);
      expect(tester.getRect(find.byKey(SignInPage.scenePaneKey)).width, 430);
      expect(
        tester.getRect(find.byKey(SignInPage.formPaneKey)).left,
        450,
      );
    });

    testWidgets('right-to-left puts the scene pane on the right', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(1194, 834),
        locale: const Locale('he'),
      );

      final scene = tester.getRect(find.byKey(SignInPage.scenePaneKey));
      final form = tester.getRect(find.byKey(SignInPage.formPaneKey));
      expect(scene.right, 1194);
      expect(scene.left, 597);
      expect(form.right, lessThanOrEqualTo(597));
    });

    testWidgets('a small phone scrolls the scene but keeps the button on '
        'screen', (tester) async {
      await pumpPage(tester, size: const Size(320, 480));

      final buttonRect = tester.getRect(find.byType(AppGoogleSignInButton));
      expect(buttonRect.bottom, lessThanOrEqualTo(480));

      await tester.drag(
        find.byKey(SignInPage.compactLayoutKey),
        const Offset(0, -200),
      );
      await tester.pump();

      expect(
        tester.getRect(find.byType(AppGoogleSignInButton)),
        buttonRect,
      );
      expect(
        tester.getTopLeft(find.byKey(SignInPage.scenePaneKey)).dy,
        lessThan(0),
      );
    });
  });

  group('SignInPage scene', () {
    Offset layerTopLeft(WidgetTester tester, String layer) =>
        tester.getTopLeft(find.byKey(WaterScene.layerKey(layer)));

    testWidgets('builds in light and dark', (tester) async {
      await pumpPage(tester);
      expect(find.byKey(SignInPage.scenePaneKey), findsOneWidget);

      await pumpPage(tester, brightness: Brightness.dark);
      await tester.pumpAndSettle();
      expect(find.byKey(SignInPage.scenePaneKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('describes Dash to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpPage(tester);

      expect(
        find.bySemanticsLabel(
          'Dash, a blue bird in a green hoodie, wading in teal water and '
          'holding up a card.',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('tilt moves near layers further than far layers', (
      tester,
    ) async {
      await pumpPage(tester);
      final skyBefore = layerTopLeft(tester, 'sky');
      final frontBefore = layerTopLeft(tester, 'front');

      tilt.tilt(const Offset(1, 0));
      await tester.pumpAndSettle();

      final skyShift = layerTopLeft(tester, 'sky') - skyBefore;
      final frontShift = layerTopLeft(tester, 'front') - frontBefore;
      expect(skyShift.dx, -2);
      expect(frontShift.dx, -16);
    });

    Future<(Offset, Offset)> scrollScene(WidgetTester tester) async {
      final skyBefore = layerTopLeft(tester, 'sky');
      final frontBefore = layerTopLeft(tester, 'front');

      await tester.drag(
        find.byKey(SignInPage.compactLayoutKey),
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();

      return (
        layerTopLeft(tester, 'sky') - skyBefore,
        layerTopLeft(tester, 'front') - frontBefore,
      );
    }

    testWidgets('scrolling moves far layers slower than near ones', (
      tester,
    ) async {
      await pumpPage(tester, size: const Size(320, 480));

      final (sky, front) = await scrollScene(tester);

      expect(front.dy, lessThan(0));
      expect(sky.dy, closeTo(front.dy * 0.3, 1));
    });

    testWidgets('Reduce Motion scrolls the scene as one picture', (
      tester,
    ) async {
      await pumpPage(
        tester,
        size: const Size(320, 480),
        disableAnimations: true,
      );

      final (sky, front) = await scrollScene(tester);

      expect(front.dy, lessThan(0));
      expect(sky.dy, front.dy);
    });

    testWidgets('Reduce Motion keeps the sensors off and the layers still', (
      tester,
    ) async {
      await pumpPage(tester, disableAnimations: true);

      expect(tilt.isListening, isFalse);
    });

    testWidgets('stops listening when the app goes to the background', (
      tester,
    ) async {
      await pumpPage(tester);
      expect(tilt.isListening, isTrue);

      Future<void> moveTo(List<AppLifecycleState> states) async {
        states.forEach(tester.binding.handleAppLifecycleStateChanged);
        await tester.pump();
      }

      await moveTo(const [.inactive, .hidden, .paused]);
      expect(tilt.isListening, isFalse);

      await moveTo(const [.hidden, .inactive, .resumed]);
      expect(tilt.isListening, isTrue);
    });
  });
}
