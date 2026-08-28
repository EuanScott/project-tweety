import 'package:material_ui/material_ui.dart';

import '../catalog/gallery_catalog.dart';
import '../catalog/gallery_entry.dart';
import 'gallery_header.dart';
import 'gallery_nav.dart';
import 'not_yet_implemented.dart';

/// The gallery's persistent chrome: categorized nav on the left, the
/// selected entry's showcase (or a not-yet-implemented placeholder) on the
/// right.
class const GalleryShell({super.key}) extends StatefulWidget {
  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  GalleryEntry _selected = galleryCatalog.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: GalleryNav(
              selected: _selected,
              onSelected: (entry) => setState(() => _selected = entry),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                GalleryHeader(title: _selected.label),
                const Divider(height: 1),
                Expanded(
                  child:
                      _selected.showcaseBuilder?.call(context) ??
                      const NotYetImplemented(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
