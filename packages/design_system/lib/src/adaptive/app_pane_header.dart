import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// Names what a pane of a split layout shows, without the back button of a
/// navigation bar: the pane is part of the page above it, not a page of its
/// own.
///
/// Cupertino centres the title inline in the navigation bar's title style.
/// Material starts the title at the leading edge in the app bar's title style.
class const AppPaneHeader({required final String title, super.key})
    extends StatelessWidget {
  static const double _cupertinoHeight = 44;
  static const double _materialHeight = 56;
  static const EdgeInsetsGeometry _padding = .symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return SizedBox(
        height: _cupertinoHeight,
        child: Center(
          child: Text(
            title,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return SizedBox(
      height: _materialHeight,
      child: Padding(
        padding: _padding,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            title,
            style:
                theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
      ),
    );
  }
}
