import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

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
class const AppModal({required final Widget child, super.key})
    extends StatelessWidget {
  /// The default height of the modal, that can be overridden.
  ///
  /// Kept well short of full-screen so the sheet reads as a partial overlay
  /// (background/scrim still visible above it) rather than a new screen.
  /// Callers with genuinely large content (e.g. a long form on [page]) can
  /// still pass a larger `maxHeightFactor` explicitly.
  static const double standardMaxHeightFactor = 0.80;

  /// Shows the standard app bottom-sheet modal.
  ///
  /// [context] is used to resolve the [Navigator] and [Theme].
  /// [child] is the widget rendered inside the modal.
  /// [borderRadius] controls the top-left and top-right corners of the sheet.
  /// [canPop] determines whether the system back action can close the modal.
  /// [maxHeightFactor] limits the modal height as a fraction of the screen height.
  /// [showDragHandle] shows the Material drag handle at the top of the sheet.
  /// [useSafeArea] prevents the sheet from overlapping system UI insets.
  /// [showCloseButton] shows a close icon that always pops the modal, on the
  /// Cupertino presentation only. The Material presentation never shows one —
  /// its drag handle and tap-outside dismissal already provide a discoverable
  /// way out.
  static Future<T?> page<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = DesignSystemBottomSheetTheme.radius,
    bool canPop = true,
    double maxHeightFactor = standardMaxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool showCloseButton = true,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      showCloseButton: showCloseButton,
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
  ///
  /// This variant never renders a close icon. Since `canPop`, tap-outside,
  /// and drag are all disabled here, [child] must supply its own resolving
  /// action (e.g. Confirm/Cancel buttons) that calls `Navigator.pop` —
  /// otherwise the modal has no way to be dismissed at all.
  static Future<T?> blocking<T>({
    required BuildContext context,
    required Widget child,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    BorderRadiusGeometry borderRadius = DesignSystemBottomSheetTheme.radius,
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
      showCloseButton: false,
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
  /// [showCloseButton] shows a close icon that always pops the modal, on the
  /// Cupertino presentation only. The Material presentation never shows one —
  /// its drag handle and tap-outside dismissal already provide a discoverable
  /// way out.
  static Future<T?> compact<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = DesignSystemBottomSheetTheme.radius,
    bool canPop = true,
    double? maxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = false,
    bool showCloseButton = true,
  }) {
    return _show<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      showCloseButton: showCloseButton,
    );
  }

  /// Internal modal implementation shared by the public modal variants.
  ///
  /// Dispatches to a Material bottom sheet or a Cupertino modal popup based
  /// on [AppDesignPlatform.of].
  static Future<T?> _show<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    bool canPop = true,
    BoxConstraints? constraints,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeightFactor,
    bool showDragHandle = false,
    bool useSafeArea = false,
    bool useRootNavigator = false,
    bool showCloseButton = true,
  }) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return _showCupertino<T>(
        context: context,
        child: child,
        borderRadius: borderRadius,
        canPop: canPop,
        isDismissible: isDismissible,
        maxHeightFactor: maxHeightFactor,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        showCloseButton: showCloseButton,
      );
    }

    return _showMaterial<T>(
      context: context,
      child: child,
      borderRadius: borderRadius,
      canPop: canPop,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      maxHeightFactor: maxHeightFactor,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
    );
  }

  /// Shows the modal as a Material bottom sheet.
  static Future<T?> _showMaterial<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    required bool canPop,
    required bool enableDrag,
    required bool isScrollControlled,
    required bool isDismissible,
    required double? maxHeightFactor,
    required bool showDragHandle,
    required bool useSafeArea,
    required bool useRootNavigator,
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
      builder: (builderContext) => PopScope(
        canPop: canPop,
        child: AppModal(child: child),
      ),
    );
  }

  /// Shows the modal as a Cupertino modal popup.
  ///
  /// `enableDrag`, `showDragHandle`, and `isScrollControlled` have no
  /// Cupertino analogue and are intentionally not translated here.
  static Future<T?> _showCupertino<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    required bool canPop,
    required bool isDismissible,
    required double? maxHeightFactor,
    required bool useSafeArea,
    required bool useRootNavigator,
    required bool showCloseButton,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        final resolvedRadius = borderRadius.resolve(Directionality.of(context));
        final sheet = ClipRRect(
          borderRadius: resolvedRadius,
          child: Container(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            constraints: _buildConstraints(
              context: context,
              maxHeightFactor: maxHeightFactor,
            ),
            child: _withCloseButton(
              context: context,
              content: AppModal(child: child),
              show: showCloseButton,
            ),
          ),
        );

        return PopScope(
          canPop: canPop,
          child: useSafeArea ? SafeArea(top: false, child: sheet) : sheet,
        );
      },
    );
  }

  /// Overlays a close icon that always pops the modal on top of [content].
  ///
  /// Cupertino-only: `showModalBottomSheet`'s drag handle and tap-outside
  /// gestures already give Material sheets a discoverable way to dismiss, so
  /// the Material presentation never renders this. Cupertino's modal popup
  /// has no equivalent built-in affordance, hence the icon here.
  ///
  /// Uses a loose [Stack] rather than a [Column] so the sheet keeps sizing
  /// itself to [content]'s natural height instead of being forced to expand.
  static Widget _withCloseButton({
    required BuildContext context,
    required Widget content,
    required bool show,
  }) {
    if (!show) {
      return content;
    }

    return Stack(
      children: [
        content,
        Positioned(
          top: 4,
          left: 4,
          child: AppIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
            semanticLabel: 'Close',
          ),
        ),
      ],
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
    final content = child;
    return content;
  }
}
