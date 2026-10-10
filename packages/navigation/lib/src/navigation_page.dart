import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the platform's native page for a `GoRoute.pageBuilder`.
///
/// iOS and macOS get a [CupertinoPage], which slides in from the trailing edge
/// and pops with an edge swipe. Every other platform gets a [MaterialPage].
/// The name and restoration id match the pages go_router builds itself.
///
/// Pass [key] to let several locations share one page. The navigator then
/// updates that page in place as the location changes, with no transition.
///
/// Routes must not rely on `GoRoute.builder`: go_router picks that page type by
/// looking for the `flutter/material` `MaterialApp`, which never matches the
/// `material_ui` app, so it falls back to a page with no transition and no
/// back gesture.
Page<void> platformPage(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  LocalKey? key,
}) {
  final name = state.name ?? state.path;
  final restorationId = state.pageKey.value;

  return switch (Theme.of(context).platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => CupertinoPage<void>(
      key: key ?? state.pageKey,
      name: name,
      restorationId: restorationId,
      child: child,
    ),
    _ => MaterialPage<void>(
      key: key ?? state.pageKey,
      name: name,
      restorationId: restorationId,
      child: child,
    ),
  };
}
