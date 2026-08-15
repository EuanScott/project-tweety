import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level tappable row that adapts between Material and Cupertino lists.
///
/// The caller owns navigation and business behavior through [onTap]. This
/// widget owns only the standard row structure and platform rendering choice.
class AppListTile extends StatelessWidget {
  /// Creates a standard adaptive list tile.
  const AppListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
        trailing:
            trailing ??
            (onTap == null ? null : const CupertinoListTileChevron()),
        onTap: onTap,
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
