import 'package:design_system/design_system.dart';
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
          ..._categorySection(context, category),
      ],
    );
  }

  List<Widget> _categorySection(
    BuildContext context,
    GalleryCategory category,
  ) {
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
      for (final entry in entries) _navRow(context, entry),
    ];
  }

  // AppListTile has no `selected` param — the selection affordance is
  // gallery-chrome behavior, so it's applied here rather than in the
  // primitive.
  Widget _navRow(BuildContext context, GalleryEntry entry) {
    final isSelected = entry.id == selected.id;

    return ColoredBox(
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withAlpha(31)
          : Colors.transparent,
      child: AppListTile(
        title: Text(entry.label),
        onTap: () => onSelected(entry),
      ),
    );
  }
}
