/// An action the person picked from the app icon's long-press menu.
///
/// [type] is the value the native shortcut declarations use: the iOS
/// `UIApplicationShortcutItemType` suffix and the Android intent action
/// suffix. Shortcuts pinned to the home screen keep it, so never rename one.
enum HomeScreenShortcut {
  createLog('createLog');

  new(this.type);

  final String type;
}
