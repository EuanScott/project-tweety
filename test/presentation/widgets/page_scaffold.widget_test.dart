import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

void main() {
  group('PageScaffold', () {
    testWidgets('renders a single body when no secondary body is provided', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        surfaceSize: const Size(900, 800),
        scaffold: const PageScaffold(title: 'Test', body: Text('Primary')),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('renders Cupertino page chrome on iOS', (tester) async {
      await _pumpScaffold(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(title: 'Test', body: Text('Primary')),
      );

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(Scaffold), findsNothing);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('renders Material page chrome on Android', (tester) async {
      await _pumpScaffold(
        tester,
        platform: TargetPlatform.android,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(title: 'Test', body: Text('Primary')),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(CupertinoPageScaffold), findsNothing);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('renders a large Cupertino title when requested on iOS', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(
          title: 'Large Title',
          titleBehavior: PageTitleBehavior.large,
          body: Text('Primary'),
        ),
      );

      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
      expect(find.text('Large Title'), findsWidgets);
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('can disable large Cupertino title collapse for short pages', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(
          title: 'Large Title',
          titleBehavior: PageTitleBehavior.largeStatic,
          body: Text('Primary'),
        ),
      );

      final nestedScrollView = tester.widget<NestedScrollView>(
        find.byType(NestedScrollView),
      );

      expect(nestedScrollView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('keeps large-title capable Android pages on Material chrome', (
      tester,
    ) async {
      final theme = DesignSystemTheme.dark().copyWith(
        platform: TargetPlatform.android,
      );

      await _pumpScaffold(
        tester,
        theme: theme,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(
          title: 'Large Title',
          titleBehavior: PageTitleBehavior.large,
          body: Text('Primary'),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(CupertinoPageScaffold), findsNothing);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    });

    testWidgets('uses dark chrome for the large Cupertino title in dark mode', (
      tester,
    ) async {
      final theme = DesignSystemTheme.dark().copyWith(
        platform: TargetPlatform.iOS,
      );

      await _pumpScaffold(
        tester,
        theme: theme,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(
          title: 'Large Title',
          titleBehavior: PageTitleBehavior.large,
          body: Text('Primary'),
        ),
      );

      final navigationBar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );

      expect(navigationBar.backgroundColor, theme.appBarTheme.backgroundColor);
    });

    testWidgets(
      'keeps default Cupertino chrome for the large title in light mode',
      (tester) async {
        final theme = DesignSystemTheme.light().copyWith(
          platform: TargetPlatform.iOS,
        );

        await _pumpScaffold(
          tester,
          theme: theme,
          surfaceSize: const Size(400, 800),
          scaffold: const PageScaffold(
            title: 'Large Title',
            titleBehavior: PageTitleBehavior.large,
            body: Text('Primary'),
          ),
        );

        final navigationBar = tester.widget<CupertinoSliverNavigationBar>(
          find.byType(CupertinoSliverNavigationBar),
        );

        expect(navigationBar.backgroundColor, isNull);
      },
    );

    testWidgets(
      'keeps Material app bar when large Cupertino title is requested on Android',
      (tester) async {
        await _pumpScaffold(
          tester,
          surfaceSize: const Size(400, 800),
          scaffold: const PageScaffold(
            title: 'Large Title',
            titleBehavior: PageTitleBehavior.large,
            body: Text('Primary'),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
      },
    );

    testWidgets('renders the native Cupertino back button on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Navigator(
            pages: const [
              MaterialPage(child: Text('Root')),
              MaterialPage(
                child: PageScaffold(title: 'Details', body: Text('Nested')),
              ),
            ],
            onDidRemovePage: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);
    });

    testWidgets('hides secondary body below the adaptive breakpoint', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        surfaceSize: const Size(400, 800),
        scaffold: const PageScaffold(
          title: 'Test',
          body: Text('Primary'),
          secondaryBody: Text('Secondary'),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsNothing);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets('shows primary and secondary bodies at wide widths', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        surfaceSize: const Size(900, 800),
        scaffold: const PageScaffold(
          title: 'Test',
          body: Text('Primary'),
          secondaryBody: Text('Secondary'),
          primaryBodyWidth: 240,
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('keeps split panes below large Cupertino chrome', (
      tester,
    ) async {
      const primaryKey = ValueKey('Primary');
      const secondaryKey = ValueKey('Secondary');

      await _pumpScaffold(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(900, 800),
        scaffold: const PageScaffold(
          title: 'Test',
          titleBehavior: PageTitleBehavior.largeStatic,
          body: SizedBox.expand(key: primaryKey),
          secondaryBody: SizedBox.expand(key: secondaryKey),
        ),
      );

      expect(
        tester.getTopLeft(find.byKey(primaryKey)).dy,
        greaterThanOrEqualTo(56),
      );
      expect(
        tester.getTopLeft(find.byKey(primaryKey)).dy,
        lessThanOrEqualTo(72),
      );
      expect(
        tester.getTopLeft(find.byKey(secondaryKey)).dy,
        greaterThanOrEqualTo(56),
      );
      expect(
        tester.getTopLeft(find.byKey(secondaryKey)).dy,
        lessThanOrEqualTo(72),
      );
    });

    testWidgets('isolates primary scroll controllers between split panes', (
      tester,
    ) async {
      ScrollController? primaryController;
      ScrollController? secondaryController;

      await _pumpScaffold(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(900, 800),
        scaffold: PageScaffold(
          title: 'Test',
          titleBehavior: PageTitleBehavior.large,
          body: Builder(
            builder: (context) {
              primaryController = PrimaryScrollController.maybeOf(context);
              return const Text('Primary');
            },
          ),
          secondaryBody: Builder(
            builder: (context) {
              secondaryController = PrimaryScrollController.maybeOf(context);
              return const Text('Secondary');
            },
          ),
        ),
      );

      expect(primaryController, isNull);
      expect(secondaryController, isNull);
    });

    testWidgets('uses an even primary and secondary split by default', (
      tester,
    ) async {
      const primaryKey = ValueKey('Primary');
      const secondaryKey = ValueKey('Secondary');

      await _pumpScaffold(
        tester,
        surfaceSize: const Size(900, 800),
        scaffold: const PageScaffold(
          title: 'Test',
          body: SizedBox.expand(key: primaryKey),
          secondaryBody: SizedBox.expand(key: secondaryKey),
        ),
      );

      expect(
        tester.getSize(find.byKey(primaryKey)).width,
        tester.getSize(find.byKey(secondaryKey)).width,
      );
    });

    testWidgets('uses a vertical display feature below the width breakpoint', (
      tester,
    ) async {
      const primaryKey = ValueKey('Primary');
      const secondaryKey = ValueKey('Secondary');

      await _pumpScaffold(
        tester,
        surfaceSize: const Size(500, 800),
        mediaSize: const Size(580, 800),
        scaffoldOffset: const Offset(80, 0),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTWH(328, 0, 20, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        scaffold: const PageScaffold(
          title: 'Test',
          body: SizedBox.expand(key: primaryKey),
          secondaryBody: SizedBox.expand(key: secondaryKey),
        ),
      );

      expect(find.byKey(primaryKey), findsOneWidget);
      expect(find.byKey(secondaryKey), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
      expect(tester.getSize(find.byKey(primaryKey)).width, 232);
      expect(tester.getTopLeft(find.byKey(secondaryKey)).dx, 348);
    });

    testWidgets('rounds the secondary body top-left corner at wide widths', (
      tester,
    ) async {
      await _pumpScaffold(
        tester,
        surfaceSize: const Size(900, 800),
        scaffold: const PageScaffold(
          title: 'Test',
          body: Text('Primary'),
          secondaryBody: Text('Secondary'),
          primaryBodyWidth: 240,
        ),
      );

      final clip = tester.widget<ClipRRect>(
        find.ancestor(
          of: find.text('Secondary'),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(
        clip.borderRadius,
        const BorderRadius.only(topLeft: Radius.circular(16)),
      );
    });
  });
}

Future<void> _pumpScaffold(
  WidgetTester tester, {
  required Size surfaceSize,
  required PageScaffold scaffold,
  TargetPlatform platform = TargetPlatform.android,
  ThemeData? theme,
  Size? mediaSize,
  Offset scaffoldOffset = Offset.zero,
  List<DisplayFeature> displayFeatures = const [],
}) async {
  final resolvedMediaSize = mediaSize ?? surfaceSize;

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? ThemeData(platform: platform),
      home: MediaQuery(
        data: MediaQueryData(
          size: resolvedMediaSize,
          displayFeatures: displayFeatures,
        ),
        child: SizedBox.fromSize(
          size: resolvedMediaSize,
          child: Padding(
            padding: EdgeInsets.only(
              left: scaffoldOffset.dx,
              top: scaffoldOffset.dy,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.fromSize(size: surfaceSize, child: scaffold),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
