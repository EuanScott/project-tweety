import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { cards }

void main() {
  group('TabBranchResetGuard', () {
    test('awaits a reset decision and suppresses duplicate requests', () async {
      final decision = Completer<bool>();
      var requestCount = 0;
      final guard = TabBranchResetGuard<_TestTab>(
        tab: _TestTab.cards,
        onResetRequested: () {
          requestCount += 1;
          return decision.future;
        },
      );

      final firstRequest = guard.requestReset();
      final duplicateRequest = guard.requestReset();

      expect(requestCount, 1);

      decision.complete(true);

      expect(await firstRequest, isTrue);
      expect(await duplicateRequest, isFalse);
    });

    test('returns the rejected decision and accepts a later request', () async {
      var requestCount = 0;
      final guard = TabBranchResetGuard<_TestTab>(
        tab: _TestTab.cards,
        onResetRequested: () async {
          requestCount += 1;
          return requestCount == 2;
        },
      );

      expect(await guard.requestReset(), isFalse);
      expect(await guard.requestReset(), isTrue);
      expect(requestCount, 2);
    });
  });
}
