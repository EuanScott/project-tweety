import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.model.freezed.dart';

/// Who the signed-in person is, as the identity provider describes them.
///
/// A Profile is read-only in this app. Any field can be missing, and a blank
/// string counts as missing: read the `known…` getters, not the raw fields.
@freezed
abstract class Profile with _$Profile {
  const factory({
    String? displayName,
    String? email,

    /// Meaningless when there is no [knownEmail].
    @Default(false) bool isEmailVerified,
    Uri? photoUrl,
    String? phoneNumber,
  }) = _Profile;

  const new _();

  String? get knownDisplayName => _known(displayName);

  String? get knownEmail => _known(email);

  String? get knownPhoneNumber => _known(phoneNumber);

  /// The first letter of the first and last words of the name, in upper
  /// case. A one-word name gives one letter; no name gives null.
  String? get initials {
    final words = knownDisplayName?.split(RegExp(r'\s+'));
    if (words == null) {
      return null;
    }

    String initial(String word) =>
        String.fromCharCode(word.runes.first).toUpperCase();

    return words.length == 1
        ? initial(words.first)
        : initial(words.first) + initial(words.last);
  }

  static String? _known(String? value) {
    final trimmed = value?.trim();

    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
