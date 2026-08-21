import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/page_title_behavior.dart';
import 'package:project_tweety/presentation/widgets/split_pane_layout.dart';
import 'package:project_tweety/presentation/widgets/tool_bar.dart';

export 'package:project_tweety/presentation/widgets/page_title_behavior.dart';

/// A shared page shell that standardises the app scaffold structure.
///
/// This widget owns the common presentation layout for top-level and nested
/// pages:
/// - [Scaffold]
/// - [ToolBar]
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

  /// The optional typed trailing action rendered in the shared app bar.
  final ToolBarAction? trailingAction,

  /// The optional floating action button for the page.
  final Widget? floatingActionButton,

  /// How the page title should be presented.
  ///
  /// Material platforms currently render all variants with the standard
  /// [ToolBar]. Cupertino platforms render large-title variants with
  /// [CupertinoSliverNavigationBar].
  final PageTitleBehavior titleBehavior = .standard,

  /// Width at which [secondaryBody] is shown beside [body].
  final double secondaryBreakpoint = 600,

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

  /// Whether the current surface should render primary and secondary panes.
  ///
  /// Real foldable display features win over the width breakpoint so a device
  /// hinge or fold is respected even when the full window is below the tablet
  /// fallback width.
  static bool usesSplitPaneLayout(
    BuildContext context,
    BoxConstraints constraints, {
    double secondaryBreakpoint = 600,
  }) {
    return SplitPaneLayout.shouldUse(
      context,
      constraints,
      breakpoint: secondaryBreakpoint,
    );
  }

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
          middle: Text(title),
          trailing: _cupertinoTrailingAction,
        ),
        child: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      );
    }

    return Scaffold(
      appBar: ToolBar(title: title, trailingAction: trailingAction),
      body: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget? get _cupertinoTrailingAction {
    final action = trailingAction;
    if (action == null) {
      return null;
    }

    return CupertinoButton(
      padding: .zero,
      onPressed: action.onPressed,
      child: Icon(action.icon),
    );
  }
}

class const _PageScaffoldBody({
  required final PageScaffold scaffold,
  final EdgeInsetsGeometry additionalPadding = .zero,
}) extends StatefulWidget {
  @override
  State<_PageScaffoldBody> createState() => _PageScaffoldBodyState();
}

class _PageScaffoldBodyState extends State<_PageScaffoldBody> {
  Offset _globalOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    _syncGlobalOffsetAfterLayout();

    final scaffold = widget.scaffold;

    return LayoutBuilder(
      builder: (context, constraints) {
        final secondaryBody = scaffold.secondaryBody;
        final mediaQuery = MediaQuery.of(context);
        final displayFeature = SplitPaneLayout.verticalDisplayFeatureFor(
          mediaQuery,
        );
        final showSecondary =
            secondaryBody != null &&
            PageScaffold.usesSplitPaneLayout(
              context,
              constraints,
              secondaryBreakpoint: scaffold.secondaryBreakpoint,
            );
        final bodyPadding = scaffold.bodyPadding.add(widget.additionalPadding);
        final resolvedPadding = bodyPadding.resolve(Directionality.of(context));

        return Padding(
          padding: bodyPadding,
          child: showSecondary
              ? SplitPaneLayout(
                  primary: scaffold.body,
                  secondary: secondaryBody,
                  displayFeature: displayFeature,
                  constraints: constraints,
                  resolvedPadding: resolvedPadding,
                  globalOffset: _globalOffset,
                  primaryWidth: scaffold.primaryBodyWidth,
                  paneGap: scaffold.paneGap,
                )
              : scaffold.body,
        );
      },
    );
  }

  void _syncGlobalOffsetAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final globalOffset = renderObject.localToGlobal(Offset.zero);
      if (globalOffset == _globalOffset) {
        return;
      }

      setState(() {
        _globalOffset = globalOffset;
      });
    });
  }
}
