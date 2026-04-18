# Data Layer

The data layer is responsible for retrieving, shaping, and returning data for the rest of the app.

## Purpose

This layer implements repository contracts defined in the domain layer and provides the concrete
data operations those contracts need.

## Naming Convention

This document defines the naming convention for the data layer. Standardize filenames on
`feature_or_entity.role.dart`.

- use `_` inside the business name
- use `.` before the technical role

Examples:

- `card.dto.dart`
- `mock_cards.datasource.dart`
- `cards.repository_impl.dart`

## Subdirectories

### `/dtos`

Contains data transfer objects that represent raw or transported data.

**Example filename:** `card.dto.dart`

```dart
// card.dto.dart
import 'package:your_app/domain/entities/card.entity.dart';

class CardDto {
  const CardDto({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  Card toEntity() {
    return Card(
      title: title,
      description: description,
    );
  }
}
```

### `/datasources`

Contains raw data access implementations such as mock providers, API clients, local storage
adapters, or cache readers.

**Example filename:** `mock_cards.datasource.dart`

```dart
// mock_cards.datasource.dart
import 'package:your_app/data/dtos/card.dto.dart';

class MockCardsDataSource {
  Future<List<CardDto>> getCards() async {
    return const [
      CardDto(
        title: 'Card Title 1',
        description: 'Example card description.',
      ),
    ];
  }
}
```

### `/repositories`

Contains implementations of repository contracts defined in the domain layer.

**Example filename:** `cards.repository_impl.dart`

```dart
// cards.repository_impl.dart
import 'package:your_app/data/datasources/mock_cards.datasource.dart';
import 'package:your_app/domain/entities/card.entity.dart';
import 'package:your_app/domain/repositories/cards.repository.dart';

class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._mockCardsDataSource);

  final MockCardsDataSource _mockCardsDataSource;

  @override
  Future<List<Card>> getCards() async {
    final items = await _mockCardsDataSource.getCards();
    return items.map((item) => item.toEntity()).toList();
  }
}
```

### `/services`

Contains shared infrastructure helpers that communicate with external systems.

```dart
// api_service.dart
import 'package:dio/dio.dart';
import 'package:your_app/core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
}
```

## Summary

- Prefer `Dto` over `Model` in this repo.
- Keep DTOs and datasources inside the data layer.
- Return domain entities from repositories, not DTOs.
- Treat this document as the source of truth for data-layer naming.
- Older features may still use legacy names.
