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
class const GalleryNav({
  required final GalleryEntry selected,
  required final ValueChanged<GalleryEntry> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: galleryCatalog.indexOf(selected),
      onDestinationSelected: (index) => onSelected(galleryCatalog[index]),
      children: [
        for (final category in GalleryCategory.values)
          ..._categorySection(category),
      ],
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
