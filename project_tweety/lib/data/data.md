Data Layer

The Data layer is responsible for data retrieval, whether from APIs, databases, or other sources.

## Purpose

This layer implements the repository interfaces defined in the Domain layer and provides concrete
data operations.

## Subdirectories

### `/models`

Contains data transfer objects (DTOs) that represent external data structures.

**Examples:**

```dart
// user_model.dart
import 'package:your_app/domain/entities/user.dart';

class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  // Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
    );
  }
}
```

### /repositories

Contains implementations of repository interfaces defined in the Domain layer.

```dart
// user_repository_impl.dart
import 'package:your_app/data/services/api_service.dart';
import 'package:your_app/domain/entities/user.dart';
import 'package:your_app/domain/repositories/user_repository.dart';
import 'package:your_app/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;

  UserRepositoryImpl(this.apiService);

  @override
  Future<List<User>> getUsers() async {
    final response = await apiService.get('/users');
    final List<dynamic> data = response.data;

    return data
        .map((json) => UserModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<User> getUserById(int id) async {
    final response = await apiService.get('/users/$id');

    return UserModel.fromJson(response.data).toEntity();
  }
}
```

### /services

Contains services that communicate with external data sources like APIs and databases.

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

    // Add interceptors, etc.
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

// Other methods like put, delete, etc.
}
```