import 'package:material_ui/material_ui.dart';

/// Title bar above a showcase.
///
/// Uses the real [AppBar] widget so its background, foreground, and title
/// styling come straight from `appBarTheme` — the same theme the real
/// app's AppBar renders with.
class const GalleryHeader({required final String title, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}
