import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';
import 'package:project_tweety/presentation/pages/sign_in/sign_in.page.dart';
import 'package:project_tweety/presentation/widgets/account/account_avatar.widget.dart';
import 'package:project_tweety/presentation/widgets/account/account_modal.widget.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_auth_repository.dart';

void main() {
  group('Account sign-out', () {
    useAppHarness();

    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository(
        profile: const Profile(displayName: 'Ada Lovelace'),
      );
      replaceAuthRepository(repository);
    });

    for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('Home shows the avatar as an Account action on '
          '${platform.name}', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpApp(tester, platform: platform);

        expect(find.byType(AccountAvatar), findsOneWidget);
        expect(find.text('AL'), findsOneWidget);
        expect(tester.getSize(find.byType(AccountAvatar)), const Size(32, 32));
        expect(
          platform == TargetPlatform.iOS
              ? find.bySemanticsLabel('Account')
              : find.byTooltip('Account'),
          findsOneWidget,
        );
        semantics.dispose();
      });

      testWidgets('signing out from the modal lands on sign-in with nothing '
          'left over on ${platform.name}', (tester) async {
        await pumpApp(tester, platform: platform);

        await tester.tap(find.byType(AccountAvatar));
        await tester.pumpAndSettle();
        expect(find.byType(AccountModal), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(AccountModal),
            matching: find.text('Sign out'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign out').last);
        await tester.pumpAndSettle();

        expect(repository.signOutRequestCount, 1);
        expect(find.byType(SignInPage), findsOneWidget);
        expect(find.byType(AccountModal), findsNothing);
        expect(find.text('Sign out?'), findsNothing);
        expect(currentRoutePath(tester), AppRoutes.signInPath);
      });
    }
  });
}
