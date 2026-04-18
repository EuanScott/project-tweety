# Preferences Storage

This folder contains the app-owned preferences storage for small, non-secure persisted app data.

## Purpose

Use this storage for lightweight values that should remain on the user’s device across app
launches, such as:

- theme mode
- language choice
- onboarding dismissed state

## Non-Goals

Do not use this storage for:

- auth tokens
- secrets or sensitive data
- API response storage
- offline-first or syncable data
- large payloads

## Supported Values

The storage is intentionally limited to app settings and lightweight UI state:

- theme mode
- selected language code
- onboarding dismissed flag

Consumers should read and write a single preferences object through the storage service instead of
persisting arbitrary keys and values.

## Contract

The public API is intentionally small and now lives in a single file.

The storage behavior is intentionally fixed:

- one permanent shared preferences entry
- one app-owned preferences object
- startup initialization ensures defaults exist
- no expiry support
- no custom storage names

The stored preferences object currently contains default-backed values for:

- theme mode, defaulting to `ThemeMode.system`
- language code, defaulting to `en`
- onboarding dismissed flag

If storage is empty or contains invalid JSON, the service rewrites the default preferences object.

## Injection

Use constructor injection with the concrete storage service:

```dart
class ExampleService {
  ExampleService(this._appPreferencesStorage);

  final AppPreferencesStorage _appPreferencesStorage;
}
```
