import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/page_title_behavior.dart';
import 'package:project_tweety/presentation/widgets/split_pane_layout.dart';

export 'package:project_tweety/presentation/widgets/page_title_behavior.dart';

/// A typed, cross-platform trailing app-bar action.
///
/// [ToolBarAction] is the shared interface consumed by both platform
/// adapters inside [PageScaffold]: the Material branch renders it as an
/// [AppIconButton] in the [AppBar], and the Cupertino branch renders the
/// same value as an [AppIconButton] in its navigation bar. Construct one
/// [ToolBarAction] and both platforms render and behave identically —
/// callers never branch on platform themselves.
class const ToolBarAction({
  /// The icon shown for this action, on both platforms.
  required final IconData icon,

  /// The callback invoked when the action is pressed, on both platforms.
  required final VoidCallback onPressed,

  /// {@template tool_bar_action_tooltip}
  /// Announced as the Material tooltip on long-press/hover, and as the
  /// Cupertino accessibility semantic label. Defaults to an empty string,
  /// which mutes both.
  /// {@endtemplate}
  final String tooltip = '',
});

/// A shared page shell that standardises the app scaffold structure.
///
/// This widget owns the common presentation layout for top-level and nested
/// pages, and is the single interface for a page header on both platforms:
/// - [Scaffold] with a Material [AppBar], or [CupertinoPageScaffold] with
///   Cupertino navigation chrome
/// - [SafeArea]
/// - consistent body padding
///
/// Business logic such as BLoC creation, event dispatching, and navigation
/// decisions should stay in the calling page.
/// Creates a page scaffold with a standard app bar and padded safe body.
class const PageScaffold({
  /// The title rendered in the shared app bar.
  required final String title,

  /// The primary content of the page.
  required final Widget body,

  /// Optional secondary content shown beside [body] on wider layouts.
  final Widget? secondaryBody,

  /// The optional typed leading action rendered in the shared app bar.
  ///
  /// Supply this only when the platform's automatic back affordance is wrong or
  /// absent — a page reached by a cold deep link has no route to pop, so it has
  /// no automatic back button. See [ToolBarAction] for the shared
  /// cross-platform contract.
  final ToolBarAction? leadingAction,

  /// The optional typed trailing action rendered in the shared app bar. See
  /// [ToolBarAction] for the shared cross-platform contract.
  final ToolBarAction? trailingAction,

  /// The optional floating action button for the page.
  final Widget? floatingActionButton,

  /// How the page title should be presented.
  ///
  /// Material platforms currently render all variants with the standard
  /// [AppBar]. Cupertino platforms render large-title variants with
  /// [CupertinoSliverNavigationBar].
  final PageTitleBehavior titleBehavior = .standard,

  /// Optional fixed width for [body] when [secondaryBody] is visible.
  final double? primaryBodyWidth,

  /// Horizontal gap on either side of the divider between body panes.
  final double paneGap = 16,

  /// Padding applied around the safe body area.
  final EdgeInsetsGeometry bodyPadding = _bodyPadding,
  super.key,
}) extends StatelessWidget {
  static const EdgeInsets _bodyPadding = .symmetric(horizontal: 16);
  static const double _cupertinoLargeTitleBodyTopInset = 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cupertinoBackgroundColor = theme.brightness == .dark
        ? theme.appBarTheme.backgroundColor
        : null;

    if (AppDesignPlatform.of(context).isCupertino) {
      if (titleBehavior.usesLargeCupertinoTitle) {
        return CupertinoPageScaffold(
          child: NestedScrollView(
            physics: titleBehavior.allowsCupertinoCollapse
                ? null
                : const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                CupertinoSliverNavigationBar(
                  backgroundColor: cupertinoBackgroundColor,
                  leading: _cupertinoLeadingAction,
                  largeTitle: Text(title),
                  trailing: _cupertinoTrailingAction,
                ),
              ];
            },
            body: SafeArea(
              top: false,
              child: _PageScaffoldBody(
                scaffold: this,
                additionalPadding: const .only(
                  top: _cupertinoLargeTitleBodyTopInset,
                ),
              ),
            ),
          ),
        );
      }

      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: cupertinoBackgroundColor,
          leading: _cupertinoLeadingAction,
          middle: Text(title),
          trailing: _cupertinoTrailingAction,
        ),
        child: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      );
    }

    return Scaffold(
      appBar: _MaterialToolBar(
        title: title,
        leadingAction: leadingAction,
        trailingAction: trailingAction,
      ),
      body: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      floatingActionButton: floatingActionButton,
    );
  }

  /// The Cupertino counterpart of [_MaterialToolBar]'s leading action.
  Widget? get _cupertinoLeadingAction => _actionButton(leadingAction);

  /// The Cupertino counterpart of [_MaterialToolBar]'s trailing action —
  /// same [ToolBarAction], same [AppIconButton], per the shared contract on
  /// [ToolBarAction].
  Widget? get _cupertinoTrailingAction => _actionButton(trailingAction);

  static Widget? _actionButton(ToolBarAction? action) {
    if (action == null) {
      return null;
    }

    return AppIconButton(
      icon: action.icon,
      onPressed: action.onPressed,
      semanticLabel: action.tooltip,
    );
  }
}

/// The Material counterpart of [PageScaffold]'s Cupertino navigation
/// chrome. Not part of [PageScaffold]'s public interface — [PageScaffold]
/// is the single public page-header abstraction for both platforms.
class const _MaterialToolBar({
  required final String title,
  final ToolBarAction? leadingAction,
  final ToolBarAction? trailingAction,
}) extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const .fromHeight(kToolbarHeight);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      leading: leadingAction != null
          ? AppIconButton(
              icon: leadingAction!.icon,
              onPressed: leadingAction!.onPressed,
              semanticLabel: leadingAction!.tooltip,
            )
          : null,
      title: Text(title),
      actions: trailingAction != null
          ? [
              AppIconButton(
                icon: trailingAction!.icon,
                onPressed: trailingAction!.onPressed,
                semanticLabel: trailingAction!.tooltip,
              ),
            ]
          : const [],
    );
  }
}

class const _PageScaffoldBody({
  required final PageScaffold scaffold,
  final EdgeInsetsGeometry additionalPadding = .zero,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secondaryBody = scaffold.secondaryBody;
    final showSecondary =
        secondaryBody != null &&
        PaneLayoutScope.of(context) == PaneLayoutMode.split;

    return Padding(
      padding: scaffold.bodyPadding.add(additionalPadding),
      child: showSecondary
          ? SplitPaneLayout(
              primary: scaffold.body,
              secondary: secondaryBody,
              primaryWidth: scaffold.primaryBodyWidth,
              paneGap: scaffold.paneGap,
            )
          : scaffold.body,
    );
  }
}
