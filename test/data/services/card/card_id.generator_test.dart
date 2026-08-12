import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/data/services/card/card_id.generator.dart';

void main() {
  group('UuidCardIdGenerator', () {
    test('generates UUID v4 card ids', () {
      final cardId = UuidCardIdGenerator().generate();

      expect(
        cardId,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });
}
