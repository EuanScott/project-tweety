import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/wcag_contrast.dart';

const _selected = <WidgetState>{WidgetState.selected};
const _unselected = <WidgetState>{};

void main() {
  group('Navigation bar theme', () {
    test('uses a neutral bar and a soft primary indicator in light', () {
      final bar = DesignSystemTheme.light(
        brand: DesignBrands.tweetyB2c,
      ).navigationBarTheme;

      expect(bar.backgroundColor, isSameColorAs(const Color(0xFFEAECED)));
      expect(bar.indicatorColor, isSameColorAs(const Color(0xFFD0DEDE)));
      expect(
        bar.iconTheme?.resolve(_selected)?.color,
        isSameColorAs(const Color(0xFF0E7474)),
      );
      expect(
        bar.iconTheme?.resolve(_unselected)?.color,
        isSameColorAs(const Color(0x99000000)),
      );
      expect(
        bar.labelTextStyle?.resolve(_selected)?.color,
        isSameColorAs(const Color(0xDD000000)),
      );
      expect(
        bar.labelTextStyle?.resolve(_selected)?.fontWeight,
        FontWeight.w700,
      );
      expect(
        bar.labelTextStyle?.resolve(_unselected)?.color,
        isSameColorAs(const Color(0x99000000)),
      );
    });
  });

  group('Navigation rail theme', () {
    test('uses the Material 3 rail roles in light', () {
      final rail = DesignSystemTheme.light(
        brand: DesignBrands.tweetyB2c,
      ).navigationRailTheme;

      expect(rail.backgroundColor, isSameColorAs(const Color(0xFFEAECED)));
      expect(rail.indicatorColor, isSameColorAs(const Color(0xFFD0DEDE)));
      expect(rail.indicatorShape, const StadiumBorder());
      expect(
        rail.selectedIconTheme?.color,
        isSameColorAs(const Color(0xFF0E7474)),
      );
      expect(
        rail.unselectedIconTheme?.color,
        isSameColorAs(const Color(0x99000000)),
      );
      expect(
        rail.selectedLabelTextStyle?.color,
        isSameColorAs(const Color(0xDD000000)),
      );
      expect(rail.selectedLabelTextStyle?.fontWeight, FontWeight.w700);
      expect(
        rail.unselectedLabelTextStyle?.color,
        isSameColorAs(const Color(0xDD000000)),
      );
    });

    test('keeps the selected label readable on the rail', () {
      for (final brand in DesignBrands.all) {
        for (final theme in [
          DesignSystemTheme.light(brand: brand),
          DesignSystemTheme.dark(brand: brand),
        ]) {
          final rail = theme.navigationRailTheme;
          final label = rail.selectedLabelTextStyle!.color!;
          final background = rail.backgroundColor!;

          expect(label, isNot(isSameColorAs(background)));
          expect(
            contrastRatio(label, background),
            greaterThanOrEqualTo(4.5),
            reason: '${brand.name} ${theme.brightness.name}',
          );
        }
      }
    });
  });

  group('Navigation contrast', () {
    test('keeps every navigation item readable in every brand', () {
      for (final brand in DesignBrands.all) {
        for (final theme in [
          DesignSystemTheme.light(brand: brand),
          DesignSystemTheme.dark(brand: brand),
        ]) {
          final bar = theme.navigationBarTheme;
          final surface = bar.backgroundColor!;
          final indicator = bar.indicatorColor!;
          final reason = '${brand.name} ${theme.brightness.name}';

          expect(
            contrastRatio(bar.iconTheme!.resolve(_selected)!.color!, indicator),
            greaterThanOrEqualTo(3),
            reason: reason,
          );
          expect(
            contrastRatio(bar.iconTheme!.resolve(_unselected)!.color!, surface),
            greaterThanOrEqualTo(3),
            reason: reason,
          );
          expect(
            contrastRatio(
              bar.labelTextStyle!.resolve(_unselected)!.color!,
              surface,
            ),
            greaterThanOrEqualTo(4.5),
            reason: reason,
          );
          expect(
            contrastRatio(
              bar.labelTextStyle!.resolve(_selected)!.color!,
              surface,
            ),
            greaterThanOrEqualTo(4.5),
            reason: reason,
          );
        }
      }
    });
  });

  group('Cupertino sidebar contrast', () {
    // iOS systemGroupedBackground, and the navigation package's 6% tint.
    const groupedBackgroundLight = Color(0xFFF2F2F7);
    const groupedBackgroundDark = Color(0xFF000000);
    const selectionTintOpacity = 0.06;

    test('keeps primary text readable on the selected row tint', () {
      for (final brand in DesignBrands.all) {
        for (final (theme, background) in [
          (DesignSystemTheme.light(brand: brand), groupedBackgroundLight),
          (DesignSystemTheme.dark(brand: brand), groupedBackgroundDark),
        ]) {
          final primary = theme.colorScheme.primary;
          final row = Color.alphaBlend(
            primary.withValues(alpha: selectionTintOpacity),
            background,
          );

          expect(
            contrastRatio(primary, row),
            greaterThanOrEqualTo(4.5),
            reason: '${brand.name} ${theme.brightness.name}',
          );
        }
      }
    });
  });

  group('Navigation drawer theme', () {
    test('uses the navigation bar roles and a round indicator in dark', () {
      final drawer = DesignSystemTheme.dark(
        brand: DesignBrands.tweetyB2c,
      ).navigationDrawerTheme;

      expect(drawer.backgroundColor, isSameColorAs(const Color(0xFF2C2C2C)));
      expect(drawer.indicatorColor, isSameColorAs(const Color(0xFF284949)));
      expect(drawer.indicatorShape, const StadiumBorder());
      expect(
        drawer.iconTheme?.resolve(_selected)?.color,
        isSameColorAs(const Color(0xFFFFFFFF)),
      );
      expect(
        drawer.iconTheme?.resolve(_unselected)?.color,
        isSameColorAs(const Color(0xB3FFFFFF)),
      );
      expect(
        drawer.labelTextStyle?.resolve(_selected)?.color,
        isSameColorAs(const Color(0xFFFFFFFF)),
      );
      expect(
        drawer.labelTextStyle?.resolve(_selected)?.fontWeight,
        FontWeight.w700,
      );
      expect(
        drawer.labelTextStyle?.resolve(_unselected)?.color,
        isSameColorAs(const Color(0xB3FFFFFF)),
      );
    });
  });

  group('App bar theme', () {
    test('uses the neutral surface with a primary title in light', () {
      final appBar = DesignSystemTheme.light(
        brand: DesignBrands.tweetyB2c,
      ).appBarTheme;

      expect(appBar.backgroundColor, isSameColorAs(const Color(0xFFF4F6F7)));
      expect(appBar.foregroundColor, isSameColorAs(const Color(0xDD000000)));
      expect(
        appBar.titleTextStyle?.color,
        isSameColorAs(const Color(0xFF0E7474)),
      );
    });
  });

  test('the app bar title stays readable in every brand and mode', () {
    for (final brand in DesignBrands.all) {
      for (final theme in [
        DesignSystemTheme.light(brand: brand),
        DesignSystemTheme.dark(brand: brand),
      ]) {
        final appBar = theme.appBarTheme;

        expect(
          contrastRatio(appBar.titleTextStyle!.color!, appBar.backgroundColor!),
          greaterThanOrEqualTo(4.5),
          reason: '${brand.name} ${theme.brightness.name}',
        );
      }
    }
  });
}
