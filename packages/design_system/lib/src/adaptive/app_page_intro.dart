import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';
import 'grouped_surface.dart';

/// A short description of a page, shown above its first `AppListSection`.
///
/// Cupertino platforms render the text in an inset grouped card with no
/// header, spaced like an `AppListSection`. Material platforms render plain
/// text on the page background, as the top intro of a settings list.
class const AppPageIntro({
  required final String description,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _CupertinoPageIntro(description: description);
    }

    return _MaterialPageIntro(description: description);
  }
}

class const _CupertinoPageIntro({required final String description})
    extends StatelessWidget {
  // The same margin as an `AppListSection`, so the gap to the next one is 28.
  static const EdgeInsets _margin = .fromLTRB(16, 20, 16, 8);
  static const EdgeInsetsGeometry _padding = .symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const double _cardRadius = 10;
  static const double _fontSize = 15;
  static const double _lineHeight = 20;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: groupedRaisedColour(Theme.of(context)),
          borderRadius: const .all(.circular(_cardRadius)),
        ),
        child: Padding(
          padding: _padding,
          child: Text(
            description,
            style: TextStyle(
              fontSize: _fontSize,
              height: _lineHeight / _fontSize,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}

class const _MaterialPageIntro({required final String description})
    extends StatelessWidget {
  static const EdgeInsetsGeometry _padding = .fromLTRB(16, 16, 16, 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: _padding,
      child: Text(
        description,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
