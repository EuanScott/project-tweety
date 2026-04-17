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
    this.trailingAction,
    this.floatingActionButton,
    super.key,
  });

  static const EdgeInsets _bodyPadding = EdgeInsets.symmetric(horizontal: 16);

  /// The title rendered in the shared app bar.
  final String title;

  /// The primary content of the page.
  final Widget body;

  /// The optional typed trailing action rendered in the shared app bar.
  final CustomAppBarAction? trailingAction;

  /// The optional floating action button for the page.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title, trailingAction: trailingAction),
      body: SafeArea(
        child: Padding(padding: _bodyPadding, child: body),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
