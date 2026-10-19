import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'home_screen_shortcut.model.dart';

/// Reports the home screen shortcuts the person picks.
///
/// Native code holds a picked shortcut until Dart takes it, so a shortcut that
/// launched the app is not lost before the router exists.
@lazySingleton
class HomeScreenShortcutService {
  static const MethodChannel _channel = MethodChannel(
    'project_tweety/home_screen_shortcuts',
  );

  /// Emits the shortcut that launched the app, if any, when listened to, then
  /// each shortcut picked while the app is running.
  Stream<HomeScreenShortcut> watchShortcuts() {
    late final StreamController<HomeScreenShortcut> controller;

    Future<void> take() async {
      final String? type;
      try {
        type = await _channel.invokeMethod<String>('takePendingShortcut');
      } on MissingPluginException {
        return;
      }

      for (final shortcut in HomeScreenShortcut.values) {
        if (shortcut.type == type) {
          controller.add(shortcut);
        }
      }
    }

    controller = StreamController<HomeScreenShortcut>(
      onListen: () {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'shortcutPending') {
            await take();
          }
        });
        unawaited(take());
      },
      onCancel: () async {
        _channel.setMethodCallHandler(null);
        await controller.close();
      },
    );

    return controller.stream;
  }
}
