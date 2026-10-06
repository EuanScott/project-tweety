import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DesignSystemTheme colour schemes', () {
    test('the Fjord light scheme uses the light brand colours', () {
      final scheme = DesignSystemTheme.light(
        brand: DesignBrands.fjord,
      ).colorScheme;

      expect(scheme.primary, const Color(0xFF0E7474));
      expect(scheme.onPrimary, const Color(0xFFFFFFFF));
      expect(scheme.secondary, const Color(0xFF8E3B76));
      expect(scheme.onSecondary, const Color(0xFFFFFFFF));
    });

    test('the Fjord dark scheme uses the dark brand colours', () {
      final scheme = DesignSystemTheme.dark(
        brand: DesignBrands.fjord,
      ).colorScheme;

      expect(scheme.primary, const Color(0xFF1BA6A6));
      expect(scheme.onPrimary, const Color(0xFF002020));
      expect(scheme.secondary, const Color(0xFFD68FC2));
      expect(scheme.onSecondary, const Color(0xFF2E0A25));
    });

    test('onError stays white in both themes', () {
      for (final brand in DesignBrands.all) {
        expect(
          DesignSystemTheme.light(brand: brand).colorScheme.onError,
          const Color(0xFFFFFFFF),
        );
        expect(
          DesignSystemTheme.dark(brand: brand).colorScheme.onError,
          const Color(0xFFFFFFFF),
        );
      }
    });

    test('the error container suits the sign-in error message', () {
      final light = DesignSystemTheme.light(
        brand: DesignBrands.fjord,
      ).colorScheme;
      final dark = DesignSystemTheme.dark(
        brand: DesignBrands.fjord,
      ).colorScheme;

      expect(light.errorContainer, const Color(0xFFFDECEC));
      expect(light.onErrorContainer, const Color(0xFFD32F2F));
      expect(dark.errorContainer, const Color(0xFF2C2C2C));
      expect(dark.onErrorContainer, const Color(0xFFFFFFFF));
    });

    test('raised containers sit above the sheet in both themes', () {
      expect(
        DesignSystemTheme.light(
          brand: DesignBrands.fjord,
        ).colorScheme.surfaceContainer,
        const Color(0xFFFFFFFF),
      );
      expect(
        DesignSystemTheme.dark(
          brand: DesignBrands.fjord,
        ).colorScheme.surfaceContainer,
        const Color(0xFF383838),
      );
    });

    test('the status colours reach the theme', () {
      for (final theme in [
        DesignSystemTheme.light(brand: DesignBrands.fjord),
        DesignSystemTheme.dark(brand: DesignBrands.fjord),
      ]) {
        final status = DesignStatusColors.of(theme);

        expect(status.success, const Color(0xFF388E3C));
        expect(status.warning, const Color(0xFFFFA000));
      }
    });
  });
}
