import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/account/account_avatar.widget.dart';

void main() {
  final photoUrl = Uri.parse('https://example.com/ada.png');

  Future<void> pumpAvatar(WidgetTester tester, Profile profile) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DesignSystemTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: AccountAvatar(profile: profile, size: 96)),
      ),
    );
  }

  Image? photo(WidgetTester tester) {
    final images = find.byType(Image);
    if (images.evaluate().isEmpty) {
      return null;
    }

    return tester.widget<Image>(images);
  }

  group('AccountAvatar', () {
    testWidgets('shows the photo when the Profile has one', (tester) async {
      await pumpAvatar(
        tester,
        Profile(displayName: 'Ada Lovelace', photoUrl: photoUrl),
      );

      expect(
        (photo(tester)!.image as NetworkImage).url,
        'https://example.com/ada.png',
      );
      expect(tester.getSize(find.byType(AccountAvatar)), const Size(96, 96));
    });

    testWidgets('shows the initials on primary when there is no photo', (
      tester,
    ) async {
      await pumpAvatar(tester, const Profile(displayName: 'Ada Lovelace'));

      expect(find.text('AL'), findsOneWidget);
      expect(photo(tester), isNull);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('shows a person icon with no photo and no name', (
      tester,
    ) async {
      await pumpAvatar(tester, const Profile(email: 'ada@example.com'));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows the initials when the photo fails to load', (
      tester,
    ) async {
      await pumpAvatar(
        tester,
        Profile(displayName: 'Ada Lovelace', photoUrl: photoUrl),
      );
      await tester.pumpAndSettle();

      expect(find.text('AL'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('names the photo for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();

      await pumpAvatar(tester, Profile(photoUrl: photoUrl));
      expect(find.bySemanticsLabel('Profile photo'), findsOneWidget);

      await pumpAvatar(tester, const Profile(displayName: 'Ada'));
      expect(find.bySemanticsLabel('No profile photo'), findsOneWidget);
      expect(find.bySemanticsLabel('A'), findsNothing);
      semantics.dispose();
    });
  });
}
