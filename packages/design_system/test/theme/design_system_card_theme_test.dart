import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DesignSystemTheme cards', () {
    test('sit flat on the page in every brand and mode', () {
      for (final brand in DesignBrands.all) {
        for (final theme in [
          DesignSystemTheme.light(brand: brand),
          DesignSystemTheme.dark(brand: brand),
        ]) {
          expect(theme.cardTheme.elevation, 0, reason: brand.name);
        }
      }
    });
  });
}
