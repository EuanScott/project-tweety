import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/wcag_contrast.dart';

void main() {
  group('DesignBrands presets', () {
    test('lists the seven theme colours once each', () {
      expect(
        DesignBrands.all.map((brand) => brand.name),
        unorderedEquals(<String>[
          'Fjord',
          'Fynbos',
          'Kalahari',
          'Lyng',
          'Whin',
          'Douro',
          'Cuillin',
        ]),
      );
    });

    test('each preset has its primary colour in light and dark', () {
      const expected = <DesignBrand, (Color, Color)>{
        DesignBrands.fjord: (Color(0xFF0E7474), Color(0xFF1BA6A6)),
        DesignBrands.fynbos: (Color(0xFF56691C), Color(0xFFB5C96A)),
        DesignBrands.kalahari: (Color(0xFFA8441F), Color(0xFFF39A74)),
        DesignBrands.lyng: (Color(0xFF77449A), Color(0xFFD2A6EF)),
        DesignBrands.whin: (Color(0xFF7A5C00), Color(0xFFF2C230)),
        DesignBrands.douro: (Color(0xFF8C1D3A), Color(0xFFF0A3B5)),
        DesignBrands.cuillin: (Color(0xFF1F2326), Color(0xFFE6E8EA)),
      };

      for (final MapEntry(key: brand, value: (light, dark))
          in expected.entries) {
        expect(
          DesignSystemTheme.light(brand: brand).colorScheme.primary,
          light,
          reason: brand.name,
        );
        expect(
          DesignSystemTheme.dark(brand: brand).colorScheme.primary,
          dark,
          reason: brand.name,
        );
      }
    });

    test('the status colours are the same in every preset', () {
      for (final brand in DesignBrands.all) {
        expect(brand.success, const Color(0xFF388E3C), reason: brand.name);
        expect(brand.warning, const Color(0xFFFFA000), reason: brand.name);
      }
    });
  });

  group('Theme colour contrast', () {
    for (final brand in DesignBrands.all) {
      for (final (brightness, theme) in [
        (Brightness.light, DesignSystemTheme.light(brand: brand)),
        (Brightness.dark, DesignSystemTheme.dark(brand: brand)),
      ]) {
        final scheme = theme.colorScheme;
        final page = theme.scaffoldBackgroundColor;
        final raised = brightness == Brightness.light
            ? scheme.surfaceContainer
            : scheme.surface;

        test('${brand.name} ${brightness.name} pairs reach 4.5:1', () {
          final pairs = <String, (Color, Color)>{
            'primary / onPrimary': (scheme.onPrimary, scheme.primary),
            'secondary / onSecondary': (scheme.onSecondary, scheme.secondary),
            'primary on page': (scheme.primary, page),
            'primary on raised': (scheme.primary, raised),
            'secondary on raised': (scheme.secondary, raised),
            'onSurface on page': (scheme.onSurface, page),
          };

          for (final MapEntry(key: pair, value: (foreground, background))
              in pairs.entries) {
            expect(
              contrastRatio(foreground, background),
              greaterThanOrEqualTo(4.5),
              reason: pair,
            );
          }
        });

        testWidgets(
          '${brand.name} ${brightness.name} tinted secondary button text '
          'reaches 4.5:1',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: theme.copyWith(platform: TargetPlatform.iOS),
                home: const Center(
                  child: AppButton.secondary(
                    onPressed: _noop,
                    child: Text('Cancel'),
                  ),
                ),
              ),
            );

            final tint = tester
                .widgetList<DecoratedBox>(
                  find.ancestor(
                    of: find.text('Cancel'),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .map((box) => box.decoration)
                .whereType<BoxDecoration>()
                .map((decoration) => decoration.color)
                .nonNulls
                .single;

            expect(
              contrastRatio(scheme.primary, Color.alphaBlend(tint, page)),
              greaterThanOrEqualTo(4.5),
            );
          },
        );
      }
    }
  });
}

void _noop() {}
