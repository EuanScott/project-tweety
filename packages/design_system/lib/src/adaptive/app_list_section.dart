import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// A titled group of settings rows that adapts between iOS and Android lists.
///
/// Cupertino platforms render an inset grouped card: an upper-case header,
/// the rows in a rounded card with inset separators, and footer text under
/// the card. Material platforms render a settings list: a `primary`
/// subheader, flat rows, the footer text and a full-width divider.
///
/// The section owns its own outer spacing, so a page stacks sections in a
/// scrolling column with no padding of its own. Put sentences in [footer],
/// never in a row subtitle: a Cupertino row cuts its subtitle to one line,
/// and the footer wraps.
class const AppListSection({
  required final List<Widget> children,
  final String? header,
  final String? footer,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _CupertinoListSection(
        header: header,
        footer: footer,
        children: children,
      );
    }

    return _MaterialListSection(
      header: header,
      footer: footer,
      children: children,
    );
  }
}

/// A row inside an [AppListSection] that holds custom content, such as a
/// segmented control, rather than a single line of text.
///
/// It pads [child] to line up with the `AppListTile` rows on each platform.
/// An optional title sits above the content in the platform's row title size.
class const AppListSectionContent({
  required final Widget child,
  final String? title,
  super.key,
}) extends StatelessWidget {
  static const EdgeInsetsGeometry _cupertinoPadding = .fromSTEB(
    20,
    12,
    14,
    12,
  );
  static const EdgeInsetsGeometry _materialPadding = .symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const double _cupertinoTitleSize = 17;
  static const double _materialTitleSize = 16;
  static const double _titleGap = 10;

  @override
  Widget build(BuildContext context) {
    final isCupertino = AppDesignPlatform.of(context).isCupertino;

    return Padding(
      padding: isCupertino ? _cupertinoPadding : _materialPadding,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          if (title case final title?) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: isCupertino
                    ? _cupertinoTitleSize
                    : _materialTitleSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: _titleGap),
          ],
          child,
        ],
      ),
    );
  }
}

class const _CupertinoListSection({
  required final List<Widget> children,
  final String? header,
  final String? footer,
}) extends StatelessWidget {
  // 20 above the first section and 8 + 20 = 28 between sections.
  static const EdgeInsets _margin = .fromLTRB(16, 20, 16, 8);
  static const EdgeInsetsGeometry _labelPadding = .symmetric(horizontal: 16);
  static const double _labelGap = 6;
  static const double _labelFontSize = 13;
  static const double _cardRadius = 10;
  static const double _separatorInset = 16;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: _labelFontSize,
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );

    return Padding(
      padding: _margin,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          if (header case final header?)
            Padding(
              padding: _labelPadding.add(
                const EdgeInsets.only(bottom: _labelGap),
              ),
              child: Text(header.toUpperCase(), style: labelStyle),
            ),
          CupertinoListSection.insetGrouped(
            margin: .zero,
            backgroundColor: Colors.transparent,
            decoration: BoxDecoration(
              color: _raisedColour(Theme.of(context)),
              borderRadius: const .all(.circular(_cardRadius)),
            ),
            hasLeading: false,
            dividerMargin: _separatorInset,
            additionalDividerMargin: 0,
            children: children,
          ),
          if (footer case final footer?)
            Padding(
              padding: _labelPadding.add(const EdgeInsets.only(top: _labelGap)),
              child: Text(footer, style: labelStyle),
            ),
        ],
      ),
    );
  }

  /// White in light mode. In dark mode the scheme's `surface` is the raised
  /// colour, because the page itself uses the scaffold background.
  Color _raisedColour(ThemeData theme) {
    if (theme.brightness == .dark) {
      return theme.colorScheme.surface;
    }

    return theme.colorScheme.surfaceContainer;
  }
}

class const _MaterialListSection({
  required final List<Widget> children,
  final String? header,
  final String? footer,
}) extends StatelessWidget {
  static const EdgeInsetsGeometry _headerPadding = .fromLTRB(16, 16, 16, 8);
  static const EdgeInsetsGeometry _footerPadding = .fromLTRB(16, 0, 16, 16);
  static const EdgeInsetsGeometry _rowPadding = .symmetric(horizontal: 16);
  static const double _textSize = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        if (header case final header?)
          Padding(
            padding: _headerPadding,
            child: Text(
              header,
              style: TextStyle(
                fontSize: _textSize,
                fontWeight: .w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ListTileTheme.merge(
          contentPadding: _rowPadding,
          child: Column(
            crossAxisAlignment: .stretch,
            children: children,
          ),
        ),
        if (footer case final footer?)
          Padding(
            padding: _footerPadding,
            child: Text(
              footer,
              style: TextStyle(
                fontSize: _textSize,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
