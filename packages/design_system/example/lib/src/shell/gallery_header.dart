import 'package:material_ui/material_ui.dart';

/// Title bar above a showcase.
///
/// Local, gallery-only deviation from the shared `appBarTheme` (which
/// renders a solid primary-teal bar, matching the real app's AppBar):
/// this header stays the same near-white surface color as the sub-header
/// controls area below it, per an explicit design call for this screen.
class const GalleryHeader({required final String title, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: Text(title),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
    );
  }
}
