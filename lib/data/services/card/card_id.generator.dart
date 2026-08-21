import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

abstract interface class CardIdGenerator {
  String generate();
}

@LazySingleton(as: CardIdGenerator)
class UuidCardIdGenerator implements CardIdGenerator {
  new() : _uuid = Uuid();

  final Uuid _uuid;

  @override
  String generate() => _uuid.v4();
}
