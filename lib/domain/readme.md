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

- `card.entity.dart`
- `cards.repository.dart`
- `get_cards.usecase.dart`
- `create_card.usecase.dart`
- `update_card.usecase.dart`
- `delete_card.usecase.dart`

## Subdirectories

### `/entities`

Contains business objects that represent core concepts in the app.

**Example filename:** `card.entity.dart`

```dart
// card.entity.dart
class Card {
  const Card({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
```

### `/repositories`

Contains contracts for data operations. The domain layer defines what it needs while the data layer
provides the implementation.

**Example filename:** `cards.repository.dart`

```dart
// cards.repository.dart
import 'package:your_app/domain/entities/card.entity.dart';

abstract class CardsRepository {
  Future<List<Card>> getCards();
  Future<Card?> getCardById(String cardId);
  Future<Card> createCard(Card card);
  Future<Card> updateCard(Card card);
  Future<void> deleteCard(String cardId);
}
```

### `/usecases`

Contains focused business operations that the presentation layer can call.

**Example filenames:** `get_cards.usecase.dart` and `create_card.usecase.dart`

```dart
// get_cards.usecase.dart
import 'package:your_app/domain/entities/card.entity.dart';
import 'package:your_app/domain/repositories/cards.repository.dart';

class GetCardsUseCase {
  const GetCardsUseCase(this._repository);

  final CardsRepository _repository;

  Future<List<Card>> call() {
    return _repository.getCards();
  }
}

// create_card.usecase.dart
import 'package:your_app/domain/entities/card.entity.dart';
import 'package:your_app/domain/repositories/cards.repository.dart';

class CreateCardUseCase {
  const CreateCardUseCase(this._repository);

  final CardsRepository _repository;

  Future<Card> call(Card card) {
    return _repository.createCard(card);
  }
}
```

## Summary

- Keep entities lightweight and framework-light.
- Keep repository contracts intent-based.
- Prefer one use case per focused app action.
- Treat this document as the source of truth for domain-layer naming.
- Older features may still use legacy names.
