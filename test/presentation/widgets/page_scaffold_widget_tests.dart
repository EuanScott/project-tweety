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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: surfaceSize, child: scaffold),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
