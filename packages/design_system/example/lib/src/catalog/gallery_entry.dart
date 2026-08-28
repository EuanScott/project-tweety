import 'package:material_ui/material_ui.dart';

import 'gallery_category.dart';

/// Builds a showcase page for the given [brightness].
typedef GalleryShowcaseBuilder = Widget Function(
  BuildContext context,
  Brightness brightness,
);

/// One nav entry in the component gallery.
///
/// A null [showcaseBuilder] renders as not-yet-implemented in the gallery
/// shell.
class const GalleryEntry({
  required final String id,
  required final String label,
  required final GalleryCategory category,
  final GalleryShowcaseBuilder? showcaseBuilder,
});
