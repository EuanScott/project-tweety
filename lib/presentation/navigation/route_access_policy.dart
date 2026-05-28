import 'routes.dart';

/// App-owned route access rules.
///
/// Keep policy decisions here so `router.dart` can stay focused on composing
/// the route tree and adapting decisions into go_router redirects.
class RouteAccessPolicy {
  const RouteAccessPolicy({required this.canAccessSettings});

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
  const RouteGuardDecision.allow() : redirectPath = null;

  const RouteGuardDecision.redirect(this.redirectPath);

  final String? redirectPath;
}
