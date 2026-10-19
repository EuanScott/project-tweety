import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/platform/home_screen_shortcut.model.dart';
import 'package:project_tweety/core/platform/home_screen_shortcut.service.dart';

const _channel = MethodChannel('project_tweety/home_screen_shortcuts');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String?> pending;
  late List<HomeScreenShortcut> received;
  StreamSubscription<HomeScreenShortcut>? subscription;

  setUp(() {
    pending = [];
    received = [];
    messenger.setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'takePendingShortcut') {
        return pending.isEmpty ? null : pending.removeAt(0);
      }

      return null;
    });
  });

  tearDown(() async {
    await subscription?.cancel();
    subscription = null;
    messenger.setMockMethodCallHandler(_channel, null);
  });

  void listen() {
    subscription = HomeScreenShortcutService().watchShortcuts().listen(
      received.add,
    );
  }

  /// Sends the native signal that a shortcut is waiting to be taken.
  Future<void> signalPending() async {
    await messenger.handlePlatformMessage(
      _channel.name,
      _channel.codec.encodeMethodCall(const MethodCall('shortcutPending')),
      (_) {},
    );
    await pumpEventQueue();
  }

  group('HomeScreenShortcutService', () {
    test('emits the shortcut that launched the app', () async {
      pending = ['createLog'];

      listen();
      await pumpEventQueue();

      expect(received, [HomeScreenShortcut.createLog]);
    });

    test('emits a shortcut picked while the app is running', () async {
      listen();
      await pumpEventQueue();

      pending = ['createLog'];
      await signalPending();

      expect(received, [HomeScreenShortcut.createLog]);
    });

    test('ignores a shortcut type this version does not know', () async {
      pending = ['removedShortcut'];

      listen();
      await pumpEventQueue();

      expect(received, isEmpty);
    });

    test('stays silent on a platform without shortcuts', () async {
      messenger.setMockMethodCallHandler(_channel, null);
      final errors = <Object>[];

      subscription = HomeScreenShortcutService().watchShortcuts().listen(
        received.add,
        onError: errors.add,
      );
      await pumpEventQueue();

      expect(received, isEmpty);
      expect(errors, isEmpty);
    });
  });
}
