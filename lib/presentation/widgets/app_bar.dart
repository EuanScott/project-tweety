import 'package:flutter/material.dart';

/// A small wrapper around [AppBar] that standardises title, leading, and action
/// configuration across the app.
///
/// Use the default constructor when you want normal Flutter back button
/// behaviour via [automaticallyImplyLeading].
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: const CustomAppBar(
///     title: 'Home',
///   ),
///   body: const SizedBox.shrink(),
/// )
/// ```
///
/// Use [CustomAppBar.hiddenLeading] when you explicitly want no leading widget.
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: const CustomAppBar.hiddenLeading(
///     title: 'Root Page',
///   ),
///   body: const SizedBox.shrink(),
/// )
/// ```
///
/// Use [CustomAppBar.customLeading] when you want to provide your own leading
/// widget, such as a custom back button or menu action.
///
/// Example:
/// ```dart
/// Scaffold(
///   appBar: CustomAppBar.customLeading(
///     title: 'Details',
///     leadingButton: IconButton(
///       icon: const Icon(Icons.home),
///       onPressed: () => debugPrint('Go home'),
///     ),
///   ),
///   body: const SizedBox.shrink(),
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a standard app bar.
  ///
  /// This constructor keeps Flutter's default leading behaviour enabled unless
  /// [automaticallyImplyLeading] is set to `false`.
  ///
  /// Pass [actionButton] to render a single widget in the app bar actions area.
  const CustomAppBar({
    required this.title,
    this.actionButton = const SizedBox.shrink(),
    this.leadingButton,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  /// Creates an app bar with the leading area intentionally hidden.
  ///
  /// This is useful for top-level pages where you do not want a back button or
  /// any custom leading widget.
  const CustomAppBar.hiddenLeading({
    required this.title,
    this.actionButton = const SizedBox.shrink(),
    super.key,
  }) : leadingButton = const SizedBox.shrink(),
       automaticallyImplyLeading = false;

  ///CustomAppBar.customLeading(
  ///         title: items[_selectedIndex].label,
  ///         leadingButton: IconButton(
  ///           icon: const Icon(Icons.home),
  ///           onPressed: () => debugPrint('something'),
  ///         ),
  ///       ),
  /// Creates an app bar with a caller-provided leading widget.
  ///
  /// Use this when the page needs custom behaviour in the leading area, such as
  /// a home button, menu button, or bespoke navigation control.
  const CustomAppBar.customLeading({
    required this.title,
    required Widget this.leadingButton,
    this.actionButton = const SizedBox.shrink(),
    super.key,
  }) : automaticallyImplyLeading = false;

  /// The text shown in the centre of the app bar.
  final String title;

  /// A single widget rendered in the app bar actions area.
  final Widget actionButton;

  /// An optional widget displayed in the leading slot.
  final Widget? leadingButton;

  /// Whether Flutter should infer the default leading widget, such as a back
  /// button, when [leadingButton] is not provided.
  final bool automaticallyImplyLeading;

  /// Returns the standard Material app bar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  AppBar build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leadingButton,
      title: Text(title),
      actions: [actionButton],
    );
  }
}
