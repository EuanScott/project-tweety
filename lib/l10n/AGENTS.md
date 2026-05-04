# AGENTS.md

## Scope
- This file applies to localization and internationalization work that touches app-wide language, locale, and directionality behavior.
- In this repo, localization source files live in `lib/l10n`, while app-level locale selection and related presentation logic may live outside this folder.
- Treat this file as guidance for any agent updating ARB files, generated localizations usage, locale preferences, or RTL-aware UI behavior.

## Source Of Truth
- Human-edited localization source belongs in `lib/l10n/*.arb`.
- Generated localization files under `lib/l10n/app_localizations*.dart` are derived artifacts. Do not hand-edit them.
- Supported app-selectable languages should stay centralized in the in-code locale registry used by the settings UI. Do not duplicate locale lists across widgets, pages, and app bootstrap code.

## Current App Model
- The app supports app language override plus system fallback.
- `AppPreferences.languageCode == null` means "follow system language".
- Layout direction follows the effective locale automatically through Flutter localization delegates. Do not add a separate persisted RTL toggle unless the user explicitly asks for one.
- Theme, language, and settings-page copy should remain localization-aware.

## Best Practices
- Prefer Flutter's built-in localization flow:
  - `AppLocalizations.of(context)!`
  - `AppLocalizations.supportedLocales`
  - Flutter localization delegates on `MaterialApp`
- Prefer localized strings over inline literals in presentation code.
- Prefer interpolated ARB messages for user-facing helper text instead of assembling translated phrases manually in Dart.
- Keep string keys descriptive and feature-oriented. Follow the existing naming style such as `appPreferencesThemeLabel` or `settingsAppPreferencesSubtitle`.
- Keep copy neutral and platform-safe when a behavior differs between Android and iOS.
- If platform-specific wording is required, isolate that choice in presentation logic and keep the strings themselves explicit.

## ARB Conventions
- Add an `@key` metadata entry with a short description for every new English string.
- Keep placeholder names concrete, stable, and semantically meaningful.
- When adding a placeholder-based string in English, mirror that key across every supported locale file in the same change.
- Do not leave supported locales with missing keys unless the task explicitly allows incomplete localization work.
- Prefer natural copy over overly literal translations. If a translation is uncertain, keep the sentence structure simple.

## Locale Expansion Rules
- When adding a new supported language:
  - add a new ARB file in `lib/l10n`
  - regenerate localization output with `flutter gen-l10n`
  - update the centralized locale options registry used by the settings page
  - ensure `MaterialApp` still uses `AppLocalizations.supportedLocales`
  - update any platform declarations required for that locale, such as iOS supported localizations
- When adding an RTL language, rely on Flutter directionality from the effective locale. Do not wrap the app in custom `Directionality` unless there is a concrete bug that cannot be solved otherwise.

## Settings And Preferences
- Language settings should always support:
  - explicit language override
  - system default fallback
- Keep helper text explicit about whether the app is following the device or applying an override.
- If a settings action opens OS settings, the copy must not promise a more specific destination than the platform can reliably open.

## Editing Rules
- Do not hand-edit:
  - `lib/l10n/app_localizations.dart`
  - `lib/l10n/app_localizations_en.dart`
  - `lib/l10n/app_localizations_es.dart`
  - `lib/l10n/app_localizations_he.dart`
- After changing ARB files, regenerate with:
  - `flutter gen-l10n`
- If a Flutter command needs SDK cache access outside the workspace, request the required approval rather than working around it.

## Validation
- After localization changes, prefer targeted validation:
  - widget tests covering visible copy on the affected screen
  - widget tests covering locale switching where relevant
  - RTL verification for RTL locales when text or layout behavior changed
- At minimum, verify:
  - the app still builds generated localization classes successfully
  - no removed or renamed key is still referenced from Dart
  - settings and navigation labels update correctly after a locale switch

## Anti-Patterns
- Do not hardcode supported locales in multiple places.
- Do not persist a fake default language when the intended behavior is "follow system".
- Do not build translated sentences by concatenating fragments in Dart.
- Do not introduce custom locale or direction handling when Flutter already provides the behavior.
- Do not use private platform deep links by default; treat them as exceptions that require explicit user direction.
