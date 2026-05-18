import 'package:flutter_test/flutter_test.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { home, settings }

void main() {
  group('TabReselectController', () {
    test('runs the registered callback for a tab', () {
      final controller = TabReselectController<_TestTab>();
      var callCount = 0;

      controller.register(_TestTab.home, () => callCount += 1);

      final handled = controller.handle(_TestTab.home);

      expect(handled, isTrue);
      expect(callCount, 1);
    });

    test('returns false when no callback is registered', () {
      final controller = TabReselectController<_TestTab>();

      final handled = controller.handle(_TestTab.settings);

      expect(handled, isFalse);
    });

    test('only unregisters the active callback for a tab', () {
      final controller = TabReselectController<_TestTab>();
      var firstCallCount = 0;
      var secondCallCount = 0;

      void firstCallback() => firstCallCount += 1;
      void secondCallback() => secondCallCount += 1;

      controller
        ..register(_TestTab.home, firstCallback)
        ..register(_TestTab.home, secondCallback)
        ..unregister(_TestTab.home, firstCallback);

      final handled = controller.handle(_TestTab.home);

      expect(handled, isTrue);
      expect(firstCallCount, 0);
      expect(secondCallCount, 1);
    });
  });
}
