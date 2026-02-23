# Core Layer

The Core layer contains app-wide utilities, configurations, and helpers that are used across the
entire application.

## Purpose

This layer provides fundamental building blocks and utility functions that don't belong to any
specific feature but are used throughout the app.

## Subdirectories

### `/constants`

Contains all application-wide constant values.

**Examples:**

```dart
// api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const int timeout = 30000; // in milliseconds
}

// app_constants.dart
class AppConstants {
  static const String appName = 'My Flutter App';
  static const String appVersion = '1.0.0';
}
```

### /themes

Contains theme-related configurations.

```dart
// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      // Other theme properties
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.indigo,
      // Other theme properties
    );
  }
}
```

### /utils

Contains utility functions and helper classes.

```dart
// date_utils.dart
class DateUtils {
  static String formatDate(DateTime date) {
    // Format date logic
    return '${date.day}/${date.month}/${date.year}';
  }
}

// validation_utils.dart
class ValidationUtils {
  static bool isValidEmail(String email) {
    // Email validation logic
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
```