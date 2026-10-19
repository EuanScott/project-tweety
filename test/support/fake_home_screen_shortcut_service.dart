import 'dart:async';

import 'package:project_tweety/core/platform/home_screen_shortcut.model.dart';
import 'package:project_tweety/core/platform/home_screen_shortcut.service.dart';

/// [HomeScreenShortcutService] whose shortcuts the test picks with [pick].
class FakeHomeScreenShortcutService implements HomeScreenShortcutService {
  final _shortcuts = StreamController<HomeScreenShortcut>.broadcast(sync: true);

  @override
  Stream<HomeScreenShortcut> watchShortcuts() => _shortcuts.stream;

  void pick(HomeScreenShortcut shortcut) => _shortcuts.add(shortcut);
}
