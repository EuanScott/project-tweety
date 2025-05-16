# Domain Layer

The Domain layer contains the business logic and rules of the application.

## Purpose

This layer defines the core functionality of the application and is independent of other layers. It
contains business entities, repository interfaces, and use cases.

## Subdirectories

### `/entities`

Contains business objects/models that represent core concepts in your application.

**Examples:**

```dart
// user.dart
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// product.dart
class Product {
  final int id;
  final String name;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}
```

### /repositories

Contains interfaces that define contracts for data operations. Domain defines what it needs, while the implementation details live in the data layer.

**Examples:**
```dart
// user_repository.dart
import 'package:your_app/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(int id);
  Future<void> saveUser(User user);
  Future<void> deleteUser(int id);
}

// product_repository.dart
import 'package:your_app/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> getProductsByCategory(String category);
  Future<void> saveProduct(Product product);
}
```

### /usecases

Contains business logic units or operations that can be performed in your application.

**Examples:**

```dart
// get_users_usecase.dart
import 'package:your_app/domain/entities/user.dart';
import 'package:your_app/domain/repositories/user_repository.dart';

class GetUsersUseCase {
  final UserRepository repository;

  GetUsersUseCase(this.repository);

  Future<List<User>> execute() {
    return repository.getUsers();
  }
}

// get_user_by_id_usecase.dart
import 'package:your_app/domain/entities/user.dart';
import 'package:your_app/domain/repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<User> execute(int id) {
    return repository.getUserById(id);
  }
}
```