import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/navigation/route_access.policy.dart';

void main() {
  group('RouteAccessPolicy', () {
    test('allows settings routes when the manual setting allows access', () {
      const policy = RouteAccessPolicy(canAccessSettings: true);

      final decision = policy.settingsAccessDecision();

      expect(decision.redirectPath, isNull);
    });

    test('redirects settings routes when the manual setting denies access', () {
      const policy = RouteAccessPolicy(canAccessSettings: false);

      final decision = policy.settingsAccessDecision();

      expect(decision.redirectPath, AppRoutes.accessDeniedPath);
    });
  });

  group('RouteAccessPolicy.sessionAccessDecision', () {
    const policy = RouteAccessPolicy(canAccessSettings: true);
    const signedOut = Session.signedOut();
    const signedIn = Session.signedIn();

    String? decide(Session session, String location) {
      return policy
          .sessionAccessDecision(
            session: session,
            location: Uri.parse(location),
          )
          .redirectPath;
    }

    test('signed out, anywhere but sign-in: redirects to sign-in and carries '
        'the requested location', () {
      expect(
        decide(signedOut, '/cards/abc?tab=1'),
        '/sign-in?from=%2Fcards%2Fabc%3Ftab%3D1',
      );
    });

    test(
      'signed out, at the root: redirects to sign-in with nothing to carry',
      () {
        expect(decide(signedOut, '/'), AppRoutes.signInPath);
      },
    );

    test('signed out, on sign-in: allows', () {
      expect(decide(signedOut, '/sign-in'), isNull);
      expect(decide(signedOut, '/sign-in?from=%2Fcards'), isNull);
    });

    test('signed in, on sign-in: redirects to the carried location', () {
      expect(decide(signedIn, '/sign-in?from=%2Fcards%2Fabc'), '/cards/abc');
    });

    test('signed in, on sign-in with nothing carried: redirects to Home', () {
      expect(decide(signedIn, '/sign-in'), AppRoutes.homePath);
    });

    test('signed in, on sign-in: ignores a carried location that is not an '
        'in-app path', () {
      for (final from in [
        'https://example.com/cards',
        '//example.com/cards',
        'cards',
        '/sign-in',
        '',
      ]) {
        expect(
          decide(signedIn, '/sign-in?from=${Uri.encodeQueryComponent(from)}'),
          AppRoutes.homePath,
          reason: from,
        );
      }
    });

    test('signed in, anywhere else: allows', () {
      expect(decide(signedIn, '/cards'), isNull);
      expect(decide(signedIn, '/settings/app-preferences'), isNull);
    });
  });
}
