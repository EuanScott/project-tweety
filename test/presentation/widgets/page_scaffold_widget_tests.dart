import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  Size? mediaSize,
  Offset scaffoldOffset = Offset.zero,
  List<DisplayFeature> displayFeatures = const [],
}) async {
  final resolvedMediaSize = mediaSize ?? surfaceSize;

  await tester.pumpWidget(
    MaterialApp(
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
