import 'package:material_ui/material_ui.dart';

import '../catalog/gallery_catalog.dart';
import '../catalog/gallery_category.dart';
import '../catalog/gallery_entry.dart';

/// Categorized nav listing every entry in [galleryCatalog].
class const GalleryNav({
  required final GalleryEntry selected,
  required final ValueChanged<GalleryEntry> onSelected,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
        padding: const .fromLTRB(16, 16, 16, 8),
        child: Text(
          category.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      for (final entry in entries)
        ListTile(
          title: Text(entry.label),
          selected: entry.id == selected.id,
          onTap: () => onSelected(entry),
        ),
    ];
  }
}
