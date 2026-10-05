import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';

void main() {
  group('Profile', () {
    test('an empty Profile knows nothing', () {
      const profile = Profile();

      expect(profile.knownDisplayName, isNull);
      expect(profile.knownEmail, isNull);
      expect(profile.knownPhoneNumber, isNull);
      expect(profile.photoUrl, isNull);
      expect(profile.isEmailVerified, isFalse);
      expect(profile.initials, isNull);
    });

    test('blank strings count as missing', () {
      const profile = Profile(
        displayName: '  ',
        email: '',
        phoneNumber: '\t',
      );

      expect(profile.knownDisplayName, isNull);
      expect(profile.knownEmail, isNull);
      expect(profile.knownPhoneNumber, isNull);
      expect(profile.initials, isNull);
    });

    test('known values are trimmed', () {
      const profile = Profile(
        displayName: ' Ada Lovelace ',
        email: ' ada@example.com ',
        phoneNumber: ' +44 20 7946 0000 ',
      );

      expect(profile.knownDisplayName, 'Ada Lovelace');
      expect(profile.knownEmail, 'ada@example.com');
      expect(profile.knownPhoneNumber, '+44 20 7946 0000');
    });

    group('initials', () {
      test('use the first and last words of the name', () {
        expect(
          const Profile(displayName: 'ada king lovelace').initials,
          'AL',
        );
      });

      test('use one letter for a one-word name', () {
        expect(const Profile(displayName: 'Ada').initials, 'A');
      });

      test('ignore extra spaces between words', () {
        expect(const Profile(displayName: ' Ada   Lovelace ').initials, 'AL');
      });
    });
  });
}
