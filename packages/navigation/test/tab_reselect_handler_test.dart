import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { home, settings }

void main() {
  group('TabReselectHandler', () {
    testWidgets('registers its callback with the nearest scope', (
      tester,
    ) async {
      final controller = TabReselectController<_TestTab>();
      var callCount = 0;

      await tester.pumpWidget(
        TabReselectScope<_TestTab>(
          controller: controller,
          child: TabReselectHandler<_TestTab>(
            tab: _TestTab.home,
            onReselect: () => callCount += 1,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      final handled = controller.handle(_TestTab.home);

      expect(handled, isTrue);
      expect(callCount, 1);
    });

    testWidgets('updates registration when the tab changes', (tester) async {
      final controller = TabReselectController<_TestTab>();
      var callCount = 0;

      await tester.pumpWidget(
        _Harness(
          controller: controller,
          tab: _TestTab.home,
          onReselect: () => callCount += 1,
        ),
      );

      await tester.pumpWidget(
        _Harness(
          controller: controller,
          tab: _TestTab.settings,
          onReselect: () => callCount += 1,
        ),
      );

      expect(controller.handle(_TestTab.home), isFalse);
      expect(controller.handle(_TestTab.settings), isTrue);
      expect(callCount, 1);
    });

    testWidgets('unregisters when disposed', (tester) async {
      final controller = TabReselectController<_TestTab>();

      await tester.pumpWidget(
        _Harness(controller: controller, tab: _TestTab.home, onReselect: () {}),
      );

      await tester.pumpWidget(const SizedBox.shrink());

      expect(controller.handle(_TestTab.home), isFalse);
    });
  });
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.controller,
    required this.tab,
    required this.onReselect,
  });

  final TabReselectController<_TestTab> controller;
  final _TestTab tab;
  final VoidCallback onReselect;

  @override
  Widget build(BuildContext context) {
    return TabReselectScope<_TestTab>(
      controller: controller,
      child: TabReselectHandler<_TestTab>(
        tab: tab,
        onReselect: onReselect,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
