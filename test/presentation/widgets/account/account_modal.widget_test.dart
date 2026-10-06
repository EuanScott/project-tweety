import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/data/repositories/auth/session.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/account/account.cubit.dart';
import 'package:project_tweety/presentation/widgets/account/account_avatar.widget.dart';
import 'package:project_tweety/presentation/widgets/account/account_modal.widget.dart';

import '../../../support/fake_auth_repository.dart';

void main() {
  const name = 'Ada Lovelace';
  const email = 'ada@example.com';
  const phone = '+44 20 7946 0000';
  final photoUrl = Uri.parse('https://example.com/ada.png');
  final complete = Profile(
    displayName: name,
    email: email,
    isEmailVerified: true,
    photoUrl: photoUrl,
    phoneNumber: phone,
  );

  const signOutFootnote = 'Your Cards stay on this device when you sign out.';
  late FakeAuthRepository repository;

  Future<void> openModal(
    WidgetTester tester,
    Profile profile, {
    Size size = const Size(390, 844),
    TargetPlatform platform = TargetPlatform.android,
    Brightness brightness = Brightness.light,
    List<DisplayFeature> displayFeatures = const [],
  }) async {
    repository = FakeAuthRepository(profile: profile);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final theme = brightness == Brightness.dark
        ? DesignSystemTheme.dark()
        : DesignSystemTheme.light();

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size, displayFeatures: displayFeatures),
        child: MaterialApp(
          theme: theme.copyWith(platform: platform),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider(
            create: (_) => AccountCubit(repository),
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => unawaited(showAccountModal(context)),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  String? textOf(WidgetTester tester, Key key) {
    final finder = find.descendant(
      of: find.byKey(key),
      matching: find.byType(Text),
      matchRoot: true,
    );
    if (finder.evaluate().isEmpty) {
      return null;
    }

    return tester.widget<Text>(finder).data;
  }

  String? heading(WidgetTester tester) =>
      textOf(tester, AccountModal.headingKey);
  String? phoneLine(WidgetTester tester) =>
      textOf(tester, AccountModal.phoneLineKey);
  String? emailLine(WidgetTester tester) =>
      textOf(tester, AccountModal.emailLineKey);
  String? emailStatus(WidgetTester tester) =>
      textOf(tester, AccountModal.emailStatusKey);

  Finder inModal(Finder finder) =>
      find.descendant(of: find.byType(AccountModal), matching: finder);

  bool showsPhoto(WidgetTester tester) =>
      inModal(find.byType(Image)).evaluate().isNotEmpty;

  group('AccountModal missing data', () {
    testWidgets('complete: photo, name, number, email, verified', (
      tester,
    ) async {
      await openModal(tester, complete);

      expect(find.text('Account'), findsOneWidget);
      expect(showsPhoto(tester), isTrue);
      expect(heading(tester), name);
      expect(phoneLine(tester), phone);
      expect(emailLine(tester), email);
      expect(emailStatus(tester), 'Verified');
      expect(find.text('Google'), findsOneWidget);
      expect(
        find.text('Your Cards stay on this device when you sign out.'),
        findsOneWidget,
      );
    });

    testWidgets('no photo: initials', (tester) async {
      await openModal(tester, complete.copyWith(photoUrl: null));

      expect(showsPhoto(tester), isFalse);
      expect(inModal(find.text('AL')), findsOneWidget);
      expect(heading(tester), name);
    });

    testWidgets('no photo, no name: person icon and the email as heading', (
      tester,
    ) async {
      await openModal(
        tester,
        complete.copyWith(photoUrl: null, displayName: null),
      );

      expect(inModal(find.byIcon(Icons.person)), findsOneWidget);
      expect(heading(tester), email);
      expect(emailLine(tester), isNull);
      expect(emailStatus(tester), 'Verified');
    });

    testWidgets('no name, has photo: the email as heading', (tester) async {
      await openModal(tester, complete.copyWith(displayName: ' '));

      expect(showsPhoto(tester), isTrue);
      expect(heading(tester), email);
      expect(emailLine(tester), isNull);
    });

    testWidgets('no phone number: says so', (tester) async {
      await openModal(tester, complete.copyWith(phoneNumber: null));

      expect(phoneLine(tester), 'No phone number on this Account');
      expect(heading(tester), name);
      expect(emailLine(tester), email);
    });

    testWidgets('no email: hides the email line and says so in the row', (
      tester,
    ) async {
      await openModal(tester, complete.copyWith(email: null));

      expect(heading(tester), name);
      expect(emailLine(tester), isNull);
      expect(emailStatus(tester), 'No email on this Account');
    });

    testWidgets('email not verified: says so in the row', (tester) async {
      await openModal(tester, complete.copyWith(isEmailVerified: false));

      expect(emailLine(tester), email);
      expect(emailStatus(tester), 'Not verified');
    });

    testWidgets('no name, no email: the fallback heading', (tester) async {
      await openModal(tester, const Profile());

      expect(inModal(find.byIcon(Icons.person)), findsOneWidget);
      expect(heading(tester), 'Your Account');
      expect(phoneLine(tester), 'No phone number on this Account');
      expect(emailLine(tester), isNull);
      expect(emailStatus(tester), 'No email on this Account');
    });

    testWidgets('the phone line is always present', (tester) async {
      for (final profile in [
        complete,
        const Profile(),
        complete.copyWith(phoneNumber: null),
      ]) {
        await openModal(tester, profile);

        expect(find.byKey(AccountModal.phoneLineKey), findsOneWidget);
      }
    });

    testWidgets('builds in dark mode and on iOS', (tester) async {
      await openModal(
        tester,
        complete,
        brightness: Brightness.dark,
        platform: TargetPlatform.iOS,
      );

      expect(heading(tester), name);
      expect(tester.takeException(), isNull);
    });
  });

  group('AccountModal sign-out', () {
    AppButton signOutButton(WidgetTester tester) =>
        tester.widget<AppButton>(inModal(find.byType(AppButton)));

    Future<void> confirm(WidgetTester tester, String action) async {
      await tester.tap(inModal(find.text('Sign out')));
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsOneWidget);
      expect(
        find.text('Your Cards stay on this device. Sign in again to see them.'),
        findsOneWidget,
      );
      await tester.tap(find.text(action).last);
      await tester.pump();
    }

    testWidgets('cancel closes the dialog and changes nothing', (
      tester,
    ) async {
      await openModal(tester, complete);

      await confirm(tester, 'Cancel');
      await tester.pumpAndSettle();

      expect(find.text('Sign out?'), findsNothing);
      expect(find.byType(AccountModal), findsOneWidget);
      expect(repository.signOutRequestCount, 0);
      expect(signOutButton(tester).onPressed, isNotNull);
    });

    testWidgets('confirming disables the button while signing out', (
      tester,
    ) async {
      await openModal(tester, complete);
      repository.pendingSignOut = Completer<void>();

      await confirm(tester, 'Sign out');
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.signOutRequestCount, 1);
      expect(inModal(find.text('Signing out…')), findsOneWidget);
      expect(inModal(find.byType(AppLoadingIndicator)), findsOneWidget);
      expect(signOutButton(tester).onPressed, isNull);

      repository.pendingSignOut!.complete();
      await tester.pump();
      expect(repository.session, const Session.signedOut());
    });
  });

  group('AccountModal layout', () {
    testWidgets('a phone shows a full-width sheet', (tester) async {
      await openModal(tester, complete);

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.getSize(find.byType(AccountModal)).width, 390);
    });

    testWidgets('the Material sheet keeps the native drag handle', (
      tester,
    ) async {
      await openModal(tester, complete);

      expect(
        tester.widget<BottomSheet>(find.byType(BottomSheet)).showDragHandle,
        isTrue,
      );
    });

    testWidgets('an expanded surface shows a window at most 440 px wide', (
      tester,
    ) async {
      await openModal(tester, complete, size: const Size(1194, 834));

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(Dialog), findsOneWidget);
      expect(
        tester.getSize(find.byType(AccountModal)).width,
        lessThanOrEqualTo(440),
      );
    });

    testWidgets('an open foldable keeps the window off the hinge', (
      tester,
    ) async {
      await openModal(
        tester,
        complete,
        size: const Size(882, 800),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(430, 0, 450, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );

      final window = tester.getRect(find.byType(AccountModal));
      expect(window.right, lessThanOrEqualTo(430));
    });

    testWidgets('a small phone scrolls the whole content, scene included', (
      tester,
    ) async {
      await openModal(tester, complete, size: const Size(320, 480));
      final avatarBefore = tester.getTopLeft(
        inModal(find.byType(AccountAvatar)),
      );

      await tester.dragUntilVisible(
        inModal(find.byType(AppButton)),
        find.byType(AccountModal),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(inModal(find.byType(AccountAvatar))).dy,
        lessThan(avatarBefore.dy),
      );
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets('on $platform the sign-out sits at the bottom of the sheet', (
        tester,
      ) async {
        const phoneHeight = 844.0;
        const signOutBottomGap = 24.0;
        await openModal(tester, complete, platform: platform);

        expect(
          tester.getBottomLeft(find.text(signOutFootnote)).dy,
          moreOrLessEquals(phoneHeight - signOutBottomGap, epsilon: 1),
        );
      });
    }

    testWidgets('the avatar is 96 px in the modal', (tester) async {
      await openModal(tester, complete);

      expect(
        tester.getSize(inModal(find.byType(AccountAvatar))),
        const Size(96, 96),
      );
    });
  });
}
