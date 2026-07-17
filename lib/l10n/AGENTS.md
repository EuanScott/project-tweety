# Localization guidance

Read this for localization changes.

- Edit ARB source files, not generated localization Dart files.
- Keep keys semantic and reuse an existing key when its meaning matches.
- Run `flutter gen-l10n` after changing ARB inputs and cover visible copy in the nearest widget test.
