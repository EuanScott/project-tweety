import 'package:project_tweety/data/repositories/auth/session.model.dart';

import 'app_routes.constants.dart';

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

  /// The launch gate: a signed-out person may only see sign-in, and a
  /// signed-in person never sees it.
  ///
  /// Sign-in carries the requested [location] so that signing in returns the
  /// person to it. Only an in-app path is honoured; anything else goes Home.
  RouteGuardDecision sessionAccessDecision({
    required Session session,
    required Uri location,
  }) {
    final isOnSignIn = location.path == AppRoutes.signInPath;

    switch (session) {
      case SignedOut() when isOnSignIn:
        return const RouteGuardDecision.allow();
      case SignedOut():
        final carried = location.toString();
        if (carried == AppRoutes.rootPath) {
          return const RouteGuardDecision.redirect(AppRoutes.signInPath);
        }

        return RouteGuardDecision.redirect(
          Uri(
            path: AppRoutes.signInPath,
            queryParameters: {AppRoutes.signInFromParameter: carried},
          ).toString(),
        );
      case SignedIn() when isOnSignIn:
        final carried = location.queryParameters[AppRoutes.signInFromParameter];

        return RouteGuardDecision.redirect(
          _isInAppLocation(carried) ? carried! : AppRoutes.homePath,
        );
      case SignedIn():
        return const RouteGuardDecision.allow();
    }
  }

  bool _isInAppLocation(String? location) {
    if (location == null ||
        !location.startsWith('/') ||
        location.startsWith('//')) {
      return false;
    }

    final uri = Uri.tryParse(location);

    return uri != null &&
        !uri.hasScheme &&
        !uri.hasAuthority &&
        uri.path != AppRoutes.signInPath;
  }
}

class RouteGuardDecision {
  const new allow() : redirectPath = null;

  const new redirect(this.redirectPath);

  final String? redirectPath;
}
