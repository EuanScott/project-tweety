import 'package:flutter/material.dart';
import 'package:project_tweety/presentation/widgets/app_bar.dart';

/// A shared page shell that standardises the app scaffold structure.
///
/// This widget owns the common presentation layout for top-level and nested
/// pages:
/// - [Scaffold]
/// - [CustomAppBar]
/// - [SafeArea]
/// - consistent body padding
///
/// Business logic such as BLoC creation, event dispatching, and navigation
/// decisions should stay in the calling page.
class PageScaffold extends StatelessWidget {
  /// Creates a page scaffold with a standard app bar and padded safe body.
  const PageScaffold({
    required this.title,
    required this.body,
    this.secondaryBody,
    this.trailingAction,
    this.floatingActionButton,
    this.secondaryBreakpoint = 600,
    this.primaryBodyWidth,
    this.paneGap = 16,
    this.bodyPadding = _bodyPadding,
    super.key,
  });

  static const EdgeInsets _bodyPadding = EdgeInsets.symmetric(horizontal: 16);
  static const BorderRadius _secondaryBodyBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
  );

  /// The title rendered in the shared app bar.
  final String title;

  /// The primary content of the page.
  final Widget body;

  /// Optional secondary content shown beside [body] on wider layouts.
  final Widget? secondaryBody;

  /// The optional typed trailing action rendered in the shared app bar.
  final CustomAppBarAction? trailingAction;

  /// The optional floating action button for the page.
  final Widget? floatingActionButton;

  /// Width at which [secondaryBody] is shown beside [body].
  final double secondaryBreakpoint;

  /// Optional fixed width for [body] when [secondaryBody] is visible.
  final double? primaryBodyWidth;

  /// Horizontal gap on either side of the divider between body panes.
  final double paneGap;

  /// Padding applied around the safe body area.
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, trailingAction: trailingAction),
      body: SafeArea(child: _PageScaffoldBody(scaffold: this)),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _PageScaffoldBody extends StatelessWidget {
  const _PageScaffoldBody({required this.scaffold});

  final PageScaffold scaffold;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final secondaryBody = scaffold.secondaryBody;
        final showSecondary =
            secondaryBody != null &&
            constraints.maxWidth >= scaffold.secondaryBreakpoint;

        return Padding(
          padding: scaffold.bodyPadding,
          child: showSecondary
              ? Row(
                  children: [
                    _PrimaryPane(
                      width: scaffold.primaryBodyWidth,
                      child: scaffold.body,
                    ),
                    SizedBox(width: scaffold.paneGap),
                    const VerticalDivider(width: 1),
                    SizedBox(width: scaffold.paneGap),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: PageScaffold._secondaryBodyBorderRadius,
                        child: secondaryBody,
                      ),
                    ),
                  ],
                )
              : scaffold.body,
        );
      },
    );
  }
}

class _PrimaryPane extends StatelessWidget {
  const _PrimaryPane({required this.width, required this.child});

  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = this.width;
    if (width == null) {
      return Expanded(child: child);
    }

    return SizedBox(width: width, child: child);
  }
}
