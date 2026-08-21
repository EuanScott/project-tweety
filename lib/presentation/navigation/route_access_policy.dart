import 'routes.dart';

/// App-owned route access rules.
///
/// Keep policy decisions here so `router.dart` can stay focused on composing
/// the route tree and adapting decisions into go_router redirects.
class RouteAccessPolicy {
  const new({required this.canAccessSettings});

  /// Temporary manual tester for proving guarded navigation behavior.
  ///
  /// Replace this with auth/profile/permission state when those journeys exist.
  final bool canAccessSettings;

  RouteGuardDecision settingsAccessDecision() {
    if (canAccessSettings) {
      return const RouteGuardDecision.allow();
    }

    return const RouteGuardDecision.redirect(AppRoutes.accessDeniedPath);
  }
}

class RouteGuardDecision {
  const new allow() : redirectPath = null;

  const new redirect(this.redirectPath);

  final String? redirectPath;
}
