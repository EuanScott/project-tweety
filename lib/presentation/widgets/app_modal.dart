import 'package:flutter/material.dart';

/// Shared bottom-sheet modal wrapper used throughout the app.
///
/// Centralising modal creation here keeps the UI, UX, and calling pattern
/// consistent across all modal entry points.
///
/// This widget is only responsible for rendering the modal container. Any
/// business logic belongs to the caller or the child widget passed in.
///
/// The returned [Future<T?>] completes when the modal is dismissed and carries
/// the optional value passed to `Navigator.pop`.
class AppModal extends StatelessWidget {
  const AppModal({required this.child, super.key});

  /// The topLeft and topRight border radius to be applied to the modal.
  static const BorderRadiusGeometry defaultBorderRadius = BorderRadius.vertical(
    top: Radius.circular(16.0),
  );

  /// The default height of the modal, that can be overridden.
  static const double standardMaxHeightFactor = 0.95;

  /// The widget rendered inside the modal.
  final Widget child;

  /// Shows the standard app bottom-sheet modal.
  ///
  /// [context] is used to resolve the [Navigator] and [Theme].
  /// [child] is the widget rendered inside the modal.
  /// [borderRadius] controls the top-left and top-right corners of the sheet.
  /// [canPop] determines whether the system back action can close the modal.
  /// [maxHeightFactor] limits the modal height as a fraction of the screen height.
  /// [showDragHandle] shows the Material drag handle at the top of the sheet.
  /// [useSafeArea] prevents the sheet from overlapping system UI insets.
  static Future<T?> page<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    double maxHeightFactor = standardMaxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = true,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
    );
  }

  /// Shows a non-dismissible bottom-sheet modal.
  ///
  /// This variant disables tap-outside dismissal and drag-to-dismiss behaviour,
  /// making it suitable for forced-decision or blocking flows.
  ///
  /// [context] is used to resolve the [Navigator] and [Theme].
  /// [child] is the widget rendered inside the modal.
  /// [useSafeArea] prevents the sheet from overlapping system UI insets.
  /// [useRootNavigator] presents the modal above the root navigator when true.
  /// [borderRadius] controls the top-left and top-right corners of the sheet.
  /// [maxHeightFactor] limits the modal height as a fraction of the screen height.
  /// Pass `null` to allow the sheet to size naturally.
  /// [canPop] determines whether the system back action can close the modal.
  static Future<T?> blocking<T>({
    required BuildContext context,
    required Widget child,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    double? maxHeightFactor = standardMaxHeightFactor,
    bool canPop = false,
  }) {
    return _show<T>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      borderRadius: borderRadius,
      maxHeightFactor: maxHeightFactor,
      child: child,
      canPop: canPop,
    );
  }

  /// Shows a compact bottom-sheet modal.
  ///
  /// This variant is intended for smaller content where a full-height sheet is
  /// unnecessary.
  ///
  /// [context] is used to resolve the [Navigator] and [Theme].
  /// [child] is the widget rendered inside the modal.
  /// [borderRadius] controls the top-left and top-right corners of the sheet.
  /// [canPop] determines whether the system back action can close the modal.
  /// [maxHeightFactor] limits the modal height as a fraction of the screen
  /// height. Pass `null` to allow the sheet to size naturally.
  /// [showDragHandle] shows the Material drag handle at the top of the sheet.
  /// [useSafeArea] prevents the sheet from overlapping system UI insets.
  static Future<T?> compact<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    double? maxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = false,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
    );
  }

  /// Internal bottom-sheet implementation shared by the public modal variants.
  static Future<T?> _show<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    BoxConstraints? constraints,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeightFactor,
    bool showDragHandle = false,
    bool useSafeArea = false,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      constraints: _buildConstraints(
        context: context,
        maxHeightFactor: maxHeightFactor,
      ),
      builder: (_) => PopScope(
        canPop: canPop,
        child: AppModal(child: child),
      ),
    );
  }

  /// Builds the optional modal height constraint from [maxHeightFactor].
  static BoxConstraints? _buildConstraints({
    required BuildContext context,
    required double? maxHeightFactor,
  }) {
    if (maxHeightFactor == null) {
      return null;
    }

    return BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
    );
  }

  @override
  Widget build(BuildContext context) {
    var content = child;
    return content;
  }
}
