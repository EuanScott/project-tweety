import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/navigation/route_access_policy.dart';
import 'package:project_tweety/presentation/navigation/routes.dart';

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
}
