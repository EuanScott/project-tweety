# Domain Layer

The domain layer contains the business concepts, contracts, and operations that the rest of the app
depends on.

## Purpose

This layer defines the core functionality of the application and stays independent from presentation
details and data implementation details.

## Naming Convention

This document defines the naming convention for the domain layer. Standardize filenames on
`feature_or_entity.role.dart`.

- use `_` inside the business name
- use `.` before the technical role

Examples:

- `app_preferences.entity.dart`
- `app_preferences.repository.dart`
- `get_app_preferences.usecase.dart`
- `save_app_preferences.usecase.dart`

## Subdirectories

### `/entities`

Contains business objects that represent core concepts in the app.

**Example filename:** `app_preferences.entity.dart`

```dart
// app_preferences.entity.dart
enum AppPreferencesThemeMode { system, light, dark }

class AppPreferences {
  const AppPreferences({
    this.themeMode = AppPreferencesThemeMode.system,
    this.languageCode,
  });

  final AppPreferencesThemeMode themeMode;
  final String? languageCode;
}
```

### `/repositories`

Contains contracts for data operations. The domain layer defines what it needs while the data layer
provides the implementation.

**Example filename:** `app_preferences.repository.dart`

```dart
// app_preferences.repository.dart
import 'package:your_app/domain/entities/app_preferences.entity.dart';

abstract class AppPreferencesRepository {
  Future<AppPreferences> getAppPreferences();
  Future<void> saveAppPreferences(AppPreferences appPreferences);
}
```

### `/usecases`

Contains focused business operations that the presentation layer can call.

**Example filenames:** `get_app_preferences.usecase.dart` and `save_app_preferences.usecase.dart`

```dart
// get_app_preferences.usecase.dart
import 'package:your_app/domain/entities/app_preferences.entity.dart';
import 'package:your_app/domain/repositories/app_preferences.repository.dart';

class GetAppPreferencesUseCase {
  const GetAppPreferencesUseCase(this._repository);

  final AppPreferencesRepository _repository;

  Future<AppPreferences> call() {
    return _repository.getAppPreferences();
  }
}

// save_app_preferences.usecase.dart
import 'package:your_app/domain/entities/app_preferences.entity.dart';
import 'package:your_app/domain/repositories/app_preferences.repository.dart';

class SaveAppPreferencesUseCase {
  const SaveAppPreferencesUseCase(this._repository);

  final AppPreferencesRepository _repository;

  Future<void> call(AppPreferences appPreferences) {
    return _repository.saveAppPreferences(appPreferences);
  }
}
```

## Summary

- Keep entities lightweight and framework-light.
- Keep repository contracts intent-based.
- Prefer one use case per focused app action.
- Treat this document as the source of truth for domain-layer naming.
- Older features may still use legacy names.
