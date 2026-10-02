import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// Namespace for the app's adaptive modal entry points.
///
/// Centralising modal creation here keeps the UI, UX, and calling pattern
/// consistent across all modal entry points. This class only builds the
/// modal container; business logic belongs to the caller or the child widget
/// passed in.
///
/// Not a widget: each static method presents `child` directly (wrapped in
/// whatever chrome that presentation needs) rather than nesting it inside an
/// `AppModal` instance, so there is nothing here to construct.
///
/// The returned [Future<T?>] completes when the modal is dismissed and carries
/// the optional value passed to `Navigator.pop`.
class AppModal {
  const new _();

  /// The default height of the modal, that can be overridden.
  ///
  /// Kept well short of full-screen so the sheet reads as a partial overlay
  /// (background/scrim still visible above it) rather than a new screen.
  /// Callers with genuinely large content (e.g. a long form on [page]) can
  /// still pass a larger `maxHeightFactor` explicitly.
  static const double standardMaxHeightFactor = 0.90;

  /// The fixed width of the windowed presentation shown on expanded
  /// surfaces (tablets, foldables, wide windows) instead of a bottom sheet.
  ///
  /// See [DisplayMetrics.isExpandedSurface] for the surface check that picks
  /// this presentation.
  static const double windowedMaxWidth = 600;

  /// Shows the standard app bottom-sheet modal.
  ///
  /// [context] is used to resolve the [Navigator] and [Theme].
  /// [child] is the widget rendered inside the modal.
  /// [borderRadius] controls the top-left and top-right corners of the sheet.
  /// [canPop] determines whether the system back action can close the modal.
  /// [maxHeightFactor] limits the modal height as a fraction of the screen height.
  /// [showDragHandle] shows the Material drag handle at the top of the sheet.
  /// [useSafeArea] prevents the sheet from overlapping system UI insets.
  /// [showCloseButton] shows a close icon that always pops the modal. On the
  /// sheet presentation this only renders for Cupertino — its drag handle
  /// and tap-outside dismissal already give Material a discoverable way out.
  /// On the windowed presentation (expanded surfaces) it renders for both
  /// design languages, since windowed mode has no drag handle to fall back
  /// on. See [DisplayMetrics.isExpandedSurface].
  /// [expandToMaxHeight] pins the sheet to `maxHeightFactor` even when
  /// [child] is shorter, so its background always reaches down to that
  /// height instead of shrink-wrapping and exposing the modal barrier scrim
  /// above it. Pass `false` to let [child] size the sheet naturally, capped
  /// at `maxHeightFactor`.
  static Future<T?> page<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = DesignSystemBottomSheetTheme.radius,
    bool canPop = true,
    double maxHeightFactor = standardMaxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool showCloseButton = true,
    bool expandToMaxHeight = true,
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
      expandToMaxHeight: expandToMaxHeight,
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
    bool useRootNavigator = true,
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
      // Blocking modals stand in for a forced decision screen, so their
      // background should always reach the bottom safe area instead of
      // shrink-wrapping short content and exposing the barrier scrim below.
      expandToMaxHeight: true,
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
  /// [showCloseButton] shows a close icon that always pops the modal. On the
  /// sheet presentation this only renders for Cupertino — its drag handle
  /// and tap-outside dismissal already give Material a discoverable way out.
  /// On the windowed presentation (expanded surfaces) it renders for both
  /// design languages, since windowed mode has no drag handle to fall back
  /// on. See [DisplayMetrics.isExpandedSurface].
  /// [expandToMaxHeight] pins the sheet to `maxHeightFactor` even when
  /// [child] is shorter, so its background always reaches down to that
  /// height instead of shrink-wrapping and exposing the modal barrier scrim
  /// above it. Only applies when `maxHeightFactor` is non-null. Pass `false`
  /// to let [child] size the sheet naturally, capped at `maxHeightFactor`.
  static Future<T?> compact<T>({
    required BuildContext context,
    required Widget child,
    BorderRadiusGeometry borderRadius = DesignSystemBottomSheetTheme.radius,
    bool canPop = true,
    double? maxHeightFactor,
    bool showDragHandle = true,
    bool useSafeArea = false,
    bool showCloseButton = true,
    bool expandToMaxHeight = true,
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
      expandToMaxHeight: expandToMaxHeight,
    );
  }

  /// Internal modal implementation shared by the public modal variants.
  ///
  /// Dispatches on two independent axes: [AppDesignPlatform.of] picks
  /// Material vs. Cupertino styling, and [DisplayMetrics.isExpandedSurface]
  /// picks a sheet vs. a windowed presentation. A tablet in Cupertino mode
  /// still gets Cupertino-styled content, just inside a windowed container
  /// instead of a sheet.
  static Future<T?> _show<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    bool canPop = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeightFactor,
    bool showDragHandle = false,
    bool useSafeArea = false,
    bool useRootNavigator = true,
    bool showCloseButton = true,
    bool expandToMaxHeight = false,
  }) {
    // Read before any route is pushed: this must observe the caller's
    // surface, not whatever context showDialog/showModalBottomSheet hands
    // back to their builder later.
    final isWindowed = DisplayMetrics.isExpandedSurface(MediaQuery.of(context));

    if (AppDesignPlatform.of(context).isCupertino) {
      if (isWindowed) {
        return _showWindowedCupertino<T>(
          context: context,
          child: child,
          borderRadius: borderRadius,
          canPop: canPop,
          isDismissible: isDismissible,
          maxHeightFactor: maxHeightFactor,
          useSafeArea: useSafeArea,
          useRootNavigator: useRootNavigator,
          showCloseButton: showCloseButton,
          expandToMaxHeight: expandToMaxHeight,
        );
      }

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
        expandToMaxHeight: expandToMaxHeight,
      );
    }

    if (isWindowed) {
      return _showWindowedMaterial<T>(
        context: context,
        child: child,
        borderRadius: borderRadius,
        canPop: canPop,
        isDismissible: isDismissible,
        maxHeightFactor: maxHeightFactor,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        showCloseButton: showCloseButton,
        expandToMaxHeight: expandToMaxHeight,
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
      expandToMaxHeight: expandToMaxHeight,
    );
  }

  /// Shows the modal as a Material bottom sheet.
  ///
  /// Unlike every other presentation, this delegates close-button and
  /// safe-area handling to `showModalBottomSheet` itself instead of going
  /// through [_buildContentShell]: it never shows a close button (its drag
  /// handle and tap-outside dismissal already give a discoverable way out),
  /// and `useSafeArea` is a native parameter here.
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
    bool expandToMaxHeight = false,
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
        expandToMaxHeight: expandToMaxHeight,
      ),
      builder: (builderContext) => PopScope(canPop: canPop, child: child),
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
    bool expandToMaxHeight = false,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        final resolvedRadius = borderRadius.resolve(Directionality.of(context));
        // Safe-area padding wraps only the interactive content here, not the
        // Container below, so the sheet's background still paints flush to
        // the true screen edge instead of leaving a gap above the home
        // indicator. `safeAreaTop: false` because a bottom sheet never
        // needs top-edge inset — only the windowed presentations do.
        final body = _buildContentShell(
          context: context,
          child: child,
          showCloseButton: showCloseButton,
          useSafeArea: useSafeArea,
          isCupertino: true,
          safeAreaTop: false,
        );
        final sheet = ClipRRect(
          borderRadius: resolvedRadius,
          child: Container(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            constraints: _buildConstraints(
              context: context,
              maxHeightFactor: maxHeightFactor,
              expandToMaxHeight: expandToMaxHeight,
            ),
            child: body,
          ),
        );

        return PopScope(canPop: canPop, child: sheet);
      },
    );
  }

  /// Shows the modal as a centered Material dialog, capped at
  /// [windowedMaxWidth], for expanded surfaces (tablets, foldables, wide
  /// windows). See [DisplayMetrics.isExpandedSurface].
  ///
  /// `showDragHandle` and `enableDrag` are intentionally not accepted here:
  /// a centered dialog has no edge to drag from, so there is no drag surface
  /// to translate those flags onto.
  static Future<T?> _showWindowedMaterial<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    required bool canPop,
    required bool isDismissible,
    required double? maxHeightFactor,
    required bool useSafeArea,
    required bool useRootNavigator,
    required bool showCloseButton,
    bool expandToMaxHeight = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      builder: (builderContext) {
        final windowedRadius = _windowedRadius(builderContext, borderRadius);
        final body = _buildContentShell(
          context: builderContext,
          child: child,
          showCloseButton: showCloseButton,
          useSafeArea: useSafeArea,
          isCupertino: false,
        );

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: windowedRadius),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: _buildWindowedConstraints(
              context: context,
              maxHeightFactor: maxHeightFactor,
              expandToMaxHeight: expandToMaxHeight,
            ),
            child: PopScope(canPop: canPop, child: body),
          ),
        );
      },
    );
  }

  /// Shows the modal as a centered Cupertino dialog, capped at
  /// [windowedMaxWidth], for expanded surfaces (tablets, foldables, wide
  /// windows). See [DisplayMetrics.isExpandedSurface].
  ///
  /// Mirrors [_showCupertino]'s content shell (background container, text
  /// styling shim, safe area) via [_buildContentShell] — only the outer
  /// route API and the added width constraint differ.
  static Future<T?> _showWindowedCupertino<T>({
    required BuildContext context,
    required Widget child,
    required BorderRadiusGeometry borderRadius,
    required bool canPop,
    required bool isDismissible,
    required double? maxHeightFactor,
    required bool useSafeArea,
    required bool useRootNavigator,
    required bool showCloseButton,
    bool expandToMaxHeight = false,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        final windowedRadius = _windowedRadius(context, borderRadius);
        final body = _buildContentShell(
          context: context,
          child: child,
          showCloseButton: showCloseButton,
          useSafeArea: useSafeArea,
          isCupertino: true,
        );

        final dialog = ClipRRect(
          borderRadius: windowedRadius,
          child: Container(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            constraints: _buildWindowedConstraints(
              context: context,
              maxHeightFactor: maxHeightFactor,
              expandToMaxHeight: expandToMaxHeight,
            ),
            child: body,
          ),
        );

        return PopScope(canPop: canPop, child: dialog);
      },
    );
  }

  /// Derives an all-corner radius for the windowed presentation from
  /// [borderRadius], instead of adding a second radius parameter to every
  /// public entry point.
  ///
  /// Sheet radii are conventionally top-only (flush against the bottom
  /// edge); a floating windowed dialog needs symmetric corners, so this
  /// reuses the resolved top-left corner for all four.
  static BorderRadius _windowedRadius(
    BuildContext context,
    BorderRadiusGeometry borderRadius,
  ) {
    final resolved = borderRadius.resolve(Directionality.of(context));
    return BorderRadius.all(resolved.topLeft);
  }

  /// Builds the shared content shell: the close-button overlay, Cupertino's
  /// text-styling shim (see [_showCupertino]), and the optional safe area.
  ///
  /// Shared by every presentation except the Material sheet (see
  /// [_showMaterial]'s doc comment for why that one is exempt). Both design
  /// languages honor [showCloseButton] here, unlike the Material sheet —
  /// none of these presentations has a drag handle for Material to fall
  /// back on as a discoverable way to dismiss.
  ///
  /// [safeAreaTop] defaults to `true` for the windowed presentations, which
  /// float away from every screen edge so top inset is close to a no-op.
  /// [_showCupertino] passes `false`: a bottom sheet only ever needs
  /// bottom-edge inset.
  static Widget _buildContentShell({
    required BuildContext context,
    required Widget child,
    required bool showCloseButton,
    required bool useSafeArea,
    required bool isCupertino,
    bool safeAreaTop = true,
  }) {
    final content = isCupertino
        ? Material(
            type: MaterialType.transparency,
            textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            child: child,
          )
        : child;

    final withCloseButton = _withCloseButton(
      context: context,
      content: content,
      show: showCloseButton,
    );

    if (!useSafeArea) {
      return withCloseButton;
    }

    return SafeArea(top: safeAreaTop, child: withCloseButton);
  }

  /// Combines [_buildConstraints]'s height logic with [windowedMaxWidth],
  /// so the windowed presentation always caps width regardless of whether a
  /// height factor was supplied.
  static BoxConstraints _buildWindowedConstraints({
    required BuildContext context,
    required double? maxHeightFactor,
    bool expandToMaxHeight = false,
  }) {
    final heightConstraints = _buildConstraints(
      context: context,
      maxHeightFactor: maxHeightFactor,
      expandToMaxHeight: expandToMaxHeight,
    );

    return BoxConstraints(
      minHeight: heightConstraints?.minHeight ?? 0,
      maxHeight: heightConstraints?.maxHeight ?? double.infinity,
      maxWidth: windowedMaxWidth,
    );
  }

  /// Overlays a close icon that always pops the modal on top of [content].
  ///
  /// On the sheet presentation this is Cupertino-only: `showModalBottomSheet`'s
  /// drag handle and tap-outside gestures already give Material sheets a
  /// discoverable way to dismiss, so the Material sheet never renders this.
  /// Cupertino's modal popup has no equivalent built-in affordance, hence the
  /// icon there. The windowed presentation renders it for both design
  /// languages instead, since neither has a drag handle. See
  /// [_buildContentShell].
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
  ///
  /// [expandToMaxHeight] pins `minHeight` to the same value as `maxHeight`
  /// so the sheet always occupies exactly that height instead of
  /// shrink-wrapping short content — used by [blocking] so its background
  /// always reaches the bottom safe area rather than exposing the modal
  /// barrier beneath a short sheet.
  static BoxConstraints? _buildConstraints({
    required BuildContext context,
    required double? maxHeightFactor,
    bool expandToMaxHeight = false,
  }) {
    if (maxHeightFactor == null) {
      return null;
    }

    final height = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return BoxConstraints(
      minHeight: expandToMaxHeight ? height : 0,
      maxHeight: height,
    );
  }
}
