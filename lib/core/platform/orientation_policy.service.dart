import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps the preferred device orientations in sync with the window size.
///
/// Compact surfaces stay portrait, while tablets and unfolded/half-opened
/// foldables may also rotate to landscape. The policy is re-evaluated whenever
/// window metrics change, so folding and unfolding switches it live.
@singleton
class OrientationPolicyService with WidgetsBindingObserver {
  /// Orientations allowed on compact surfaces such as phones.
  static const List<DeviceOrientation> compactOrientations = [
    DeviceOrientation.portraitUp,
  ];

  /// Orientations allowed on tablets and unfolded foldables.
  static const List<DeviceOrientation> expandedOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  bool? _isExpanded;

  /// Applies the initial policy and starts observing window metrics changes.
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);

    await _applyForCurrentView();
  }

  /// Stops observing window metrics changes.
  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    _applyForCurrentView();
  }

  /// Applies the policy for the supplied surface.
  ///
  /// Skips the platform channel when the compact/expanded classification is
  /// unchanged, because metrics changes also fire for keyboard and inset
  /// updates.
  @visibleForTesting
  Future<void> applyFor(MediaQueryData mediaQuery) async {
    final isExpanded = DisplayMetrics.isExpandedSurface(mediaQuery);
    if (isExpanded == _isExpanded) {
      return;
    }

    _isExpanded = isExpanded;

    await SystemChrome.setPreferredOrientations(
      isExpanded ? expandedOrientations : compactOrientations,
    );
  }

  Future<void> _applyForCurrentView() async {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) {
      return;
    }

    await applyFor(MediaQueryData.fromView(view));
  }
}
