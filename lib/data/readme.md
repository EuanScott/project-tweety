# Data Layer

The data layer is responsible for retrieving, shaping, and returning data for the rest of the app.

## Purpose

This layer owns data access and can expose repository contracts directly for features that do not
need a domain layer.

## Data Shape Vocabulary

- **DTO**: a raw source, transport, or persistence shape. DTOs stay inside the data layer.
- **Repository value**: an app-facing immutable value returned by a data repository when a feature
  does not have a domain layer.
- **Domain entity**: a mobile-owned business concept used only when a feature has a justified
  domain layer.

For simple no-domain features, the normal flow is:

```text
DataSource -> Dto -> Repository -> Repository value -> BLoC/Cubit
```

When domain is justified, the repository implementation maps data-layer shapes into domain
entities instead:

```text
DataSource -> Dto -> RepositoryImpl -> Domain entity -> Use case -> BLoC/Cubit
```

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
import 'package:your_app/data/repositories/card/cards.repository.dart';

class CardDto {
  const CardDto({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  Card toValue() {
    return Card(
      id: id,
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
        id: 'card-1',
        title: 'Card Title 1',
        description: 'Example card description.',
      ),
    ];
  }
}
```

### `/repositories`

Contains repository contracts and implementations. Use data-layer contracts directly for simple
BFF-backed or CRUD-style features; use domain contracts only when the feature has mobile-owned
policy. Repository contracts may define small app-facing repository values next to the contract for
simple features. If a feature needs several repository values, move them into focused
`<entity>.value.dart` files under the same feature folder.

**Example filename:** `cards.repository_impl.dart`

```dart
// cards.repository_impl.dart
import 'package:your_app/data/datasources/mock_cards.datasource.dart';
import 'package:your_app/data/repositories/card/cards.repository.dart';

class CardsRepositoryImpl implements CardsRepository {
  const CardsRepositoryImpl(this._mockCardsDataSource);

  final MockCardsDataSource _mockCardsDataSource;

  @override
  Future<List<Card>> getCards() async {
    final items = await _mockCardsDataSource.getCards();
    return items.map((item) => item.toValue()).toList();
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
- Return repository values from no-domain repositories, not DTOs.
- Return domain entities only from repositories that implement a justified domain contract.
- Treat this document as the source of truth for data-layer naming.
- Older features may still use legacy names.
