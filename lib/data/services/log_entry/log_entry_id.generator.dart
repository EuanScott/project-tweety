import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

abstract interface class LogEntryIdGenerator {
  String generate();
}

@LazySingleton(as: LogEntryIdGenerator)
class UuidLogEntryIdGenerator implements LogEntryIdGenerator {
  new() : _uuid = Uuid();

  final Uuid _uuid;

  @override
  String generate() => _uuid.v4();
}
