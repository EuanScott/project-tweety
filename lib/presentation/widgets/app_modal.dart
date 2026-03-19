import 'package:flutter/material.dart';

class AppModal extends StatelessWidget {
  const AppModal({required this.child, super.key});

  static const BorderRadiusGeometry defaultBorderRadius = BorderRadius.vertical(
    top: Radius.circular(16.0),
  );

  static const double standardMaxHeightFactor = 0.95;

  final Widget child;

  static Future<T?> page<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    Clip clipBehavior = Clip.antiAlias,
    double maxHeightFactor = standardMaxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = true,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      clipBehavior: clipBehavior,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
    );
  }

  static Future<T?> blocking<T>({
    required BuildContext context,
    required Widget child,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    Clip clipBehavior = Clip.antiAlias,
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
      clipBehavior: clipBehavior,
      borderRadius: borderRadius,
      maxHeightFactor: maxHeightFactor,
      child: child,
      canPop: canPop,
    );
  }

  static Future<T?> compact<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    Clip clipBehavior = Clip.antiAlias,
    double? maxHeightFactor,
    bool showDragHandle = false,
    bool useSafeArea = false,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      clipBehavior: clipBehavior,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
    );
  }

  static Future<T?> _show<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = defaultBorderRadius,
    bool canPop = true,
    BoxConstraints? constraints,
    Clip clipBehavior = Clip.none,
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
      clipBehavior: clipBehavior,
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
