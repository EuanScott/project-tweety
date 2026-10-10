import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpButton(
    WidgetTester tester, {
    VoidCallback? onPressed,
    bool loading = false,
    Brightness brightness = Brightness.light,
    TargetPlatform platform = TargetPlatform.android,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness, platform: platform),
        home: Scaffold(
          body: Center(
            child: AppGoogleSignInButton(
              label: 'Sign in with Google',
              loadingLabel: 'Signing in…',
              onPressed: onPressed,
              loading: loading,
            ),
          ),
        ),
      ),
    );
  }

  Color fillColor(WidgetTester tester) {
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(AppGoogleSignInButton.surfaceKey),
                )
                .decoration
            as BoxDecoration;

    return decoration.color!;
  }

  BorderRadiusGeometry? surfaceRadius(WidgetTester tester) {
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.byKey(AppGoogleSignInButton.surfaceKey),
                )
                .decoration
            as BoxDecoration;

    return decoration.borderRadius;
  }

  group('AppGoogleSignInButton', () {
    testWidgets('shows the Google mark and label, and reports presses', (
      tester,
    ) async {
      var presses = 0;
      await pumpButton(tester, onPressed: () => presses++);

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byKey(AppGoogleSignInButton.markKey), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsNothing);

      await tester.tap(find.byType(AppGoogleSignInButton));
      expect(presses, 1);
    });

    testWidgets('shows the loading state and ignores presses while loading', (
      tester,
    ) async {
      var presses = 0;
      await pumpButton(tester, onPressed: () => presses++, loading: true);

      expect(find.text('Signing in…'), findsOneWidget);
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.text('Sign in with Google'), findsNothing);
      expect(find.byKey(AppGoogleSignInButton.markKey), findsNothing);

      await tester.tap(find.byType(AppGoogleSignInButton));
      expect(presses, 0);
      expect(
        tester.getSemantics(find.byType(AppGoogleSignInButton)),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await pumpButton(tester);

      expect(
        tester.getSemantics(find.byType(AppGoogleSignInButton)),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          label: 'Sign in with Google',
        ),
      );
    });

    testWidgets('uses the light and dark Google themes by brightness', (
      tester,
    ) async {
      await pumpButton(tester, onPressed: () {});
      expect(fillColor(tester), const Color(0xFFFFFFFF));

      await pumpButton(tester, onPressed: () {}, brightness: Brightness.dark);
      await tester.pumpAndSettle();
      expect(fillColor(tester), const Color(0xFF131314));
    });

    testWidgets('keeps the branded look on Cupertino', (tester) async {
      var presses = 0;
      await pumpButton(
        tester,
        onPressed: () => presses++,
        platform: TargetPlatform.iOS,
      );

      expect(fillColor(tester), const Color(0xFFFFFFFF));
      expect(find.byKey(AppGoogleSignInButton.markKey), findsOneWidget);

      await tester.tap(find.byType(AppGoogleSignInButton));
      expect(presses, 1);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('fills the width it is given on ${platform.name}', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: AppGoogleSignInButton(
                    label: 'Sign in with Google',
                    loadingLabel: 'Signing in…',
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        expect(
          tester.getSize(find.byKey(AppGoogleSignInButton.surfaceKey)).width,
          360,
        );
      });
    }

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets(
        'matches the app button shape and side padding on ${platform.name}',
        (tester) async {
          await pumpButton(tester, onPressed: () {}, platform: platform);

          expect(
            surfaceRadius(tester),
            const BorderRadius.all(Radius.circular(12)),
          );

          final surface = tester.getRect(
            find.byKey(AppGoogleSignInButton.surfaceKey),
          );
          final mark = tester.getRect(
            find.byKey(AppGoogleSignInButton.markKey),
          );
          final label = tester.getRect(find.text('Sign in with Google'));
          expect(mark.left - surface.left, 16);
          expect(surface.right - label.right, 16);
          expect(
            label.left - mark.right,
            platform == TargetPlatform.iOS ? 12 : 10,
          );
        },
      );
    }

    testWidgets('is at least 48 px tall', (tester) async {
      await pumpButton(tester, onPressed: () {});

      expect(
        tester.getSize(find.byType(AppGoogleSignInButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });
}
