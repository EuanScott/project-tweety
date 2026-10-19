import Flutter
import UIKit

/// Holds the home screen quick action the person picked until Dart takes it.
///
/// A quick action can launch the app before the Dart router exists, so this
/// never pushes the action itself. It stores the action, signals Dart, and
/// Dart takes it when it is ready. Taking clears it, so an action opens once.
final class HomeScreenShortcuts: NSObject, FlutterSceneLifeCycleDelegate {
  private static let channelName = "project_tweety/home_screen_shortcuts"

  private let channel: FlutterMethodChannel
  private var pendingType: String?

  private init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = HomeScreenShortcuts(
      channel: FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    )
    instance.channel.setMethodCallHandler(instance.handle)
    registrar.addSceneDelegate(instance)
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    guard let shortcutItem = connectionOptions?.shortcutItem else {
      return false
    }

    return hold(shortcutItem)
  }

  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) -> Bool {
    guard hold(shortcutItem) else {
      return false
    }

    completionHandler(true)
    return true
  }

  /// Info.plist declares each type as `<bundle id>.<Dart type>`.
  private func hold(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
    let prefix = "\(Bundle.main.bundleIdentifier ?? "")."
    guard shortcutItem.type.hasPrefix(prefix) else {
      return false
    }

    pendingType = String(shortcutItem.type.dropFirst(prefix.count))
    channel.invokeMethod("shortcutPending", arguments: nil)
    return true
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "takePendingShortcut":
      result(pendingType)
      pendingType = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
