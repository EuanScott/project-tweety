import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    Future<Size> pumpGroup(
      WidgetTester tester, {
      required double width,
      required PaneLayoutMode? mode,
    }) async {
      final group = AppButtonGroup(
        children: [
          AppButton.primary(onPressed: () {}, child: const Text('Save')),
          AppButton.secondary(onPressed: () {}, child: const Text('Cancel')),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystemTheme.light().copyWith(platform: platform),
          home: Scaffold(
            body: Align(
              alignment: .topLeft,
              child: SizedBox(
                width: width,
                child: switch (mode) {
                  null => group,
                  PaneLayoutMode.compact => PaneLayoutScope(
                    breakpoint: double.infinity,
                    child: group,
                  ),
                  PaneLayoutMode.split => PaneLayoutScope(
                    breakpoint: 0,
                    child: group,
                  ),
                },
              ),
            ),
          ),
        ),
      );
      return tester.getSize(find.byType(AppButton).first);
    }

    testWidgets('fills a single pane on ${platform.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final button = await pumpGroup(
        tester,
        width: 560,
        mode: PaneLayoutMode.compact,
      );

      expect(button.width, 560);
    });

    testWidgets('fills the width outside any pane layout on ${platform.name}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final button = await pumpGroup(tester, width: 560, mode: null);

      expect(button.width, 560);
    });

    testWidgets('stops at the pane button width and centres in a split region '
        'on ${platform.name}', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final button = await pumpGroup(
        tester,
        width: 700,
        mode: PaneLayoutMode.split,
      );
      final left = tester.getTopLeft(find.byType(AppButton).first).dx;

      expect(button.width, 480);
      expect(left, (700 - 480) / 2);
    });

    testWidgets(
      'fills a split region narrower than the cap on ${platform.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final button = await pumpGroup(
          tester,
          width: 400,
          mode: PaneLayoutMode.split,
        );

        expect(button.width, 400);
      },
    );
  }
}
