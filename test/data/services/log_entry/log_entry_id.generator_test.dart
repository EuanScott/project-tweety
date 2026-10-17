import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/services/log_entry/log_entry_id.generator.dart';

void main() {
  group('UuidLogEntryIdGenerator', () {
    test('generates UUID v4 log entry ids', () {
      final logEntryId = UuidLogEntryIdGenerator().generate();

      expect(
        logEntryId,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });
}
