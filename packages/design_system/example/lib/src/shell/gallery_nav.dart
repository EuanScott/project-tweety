import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../catalog/gallery_catalog.dart';
import '../catalog/gallery_category.dart';
import '../catalog/gallery_entry.dart';

/// Categorized nav listing every entry in [galleryCatalog].
///
/// Uses the real [NavigationDrawer] widget so its background, selection
/// indicator, and text/icon colors come straight from the app's
/// `navigationDrawerTheme` — the same theme the real app's tablet-width
/// permanent drawer renders with — instead of hand-copied color logic.
///
/// Always dark-teal, independent of the rest of the app's theme — a fixed
/// brand rail, same as many real apps' persistent nav.
class const GalleryNav({
  required final GalleryEntry selected,
  required final ValueChanged<GalleryEntry> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navTheme = DesignSystemTheme.dark(
      brand: DesignBrands.tweetyB2c,
    ).copyWith(platform: TargetPlatform.android);

    return Theme(
      data: navTheme,
      child: NavigationDrawer(
        selectedIndex: galleryCatalog.indexOf(selected),
        onDestinationSelected: (index) => onSelected(galleryCatalog[index]),
        children: [
          _Branding(colorScheme: navTheme.colorScheme),
          for (final category in GalleryCategory.values)
            ..._categorySection(category),
        ],
      ),
    );
  }

  List<Widget> _categorySection(GalleryCategory category) {
    final entries = galleryCatalog
        .where((entry) => entry.category == category)
        .toList(growable: false);

    if (entries.isEmpty) {
      return const [];
    }

    return [
      Padding(
        padding: const .fromLTRB(28, 16, 16, 8),
        child: Text(
          category.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      for (final entry in entries)
        NavigationDrawerDestination(
          icon: const Icon(Icons.widgets_outlined),
          label: Text(entry.label),
        ),
    ];
  }
}

class const _Branding({required final ColorScheme colorScheme})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: .center,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: .circular(6),
            ),
            child: Text(
              'T',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Tweety UI Kit',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
