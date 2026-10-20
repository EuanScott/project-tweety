import Flutter
import UIKit

/// Holds the home screen quick action or Control Center control the person
/// picked until Dart takes it.
///
/// Either trigger can launch the app before the Dart router exists, so this
/// never pushes the action itself. It stores the action, signals Dart, and
/// Dart takes it when it is ready. Taking clears it, so an action opens once.
///
/// The pending type and live instance are static because the control's
/// intent can run before or after `register(with:)`.
final class HomeScreenShortcuts: NSObject, FlutterSceneLifeCycleDelegate {
  private static let channelName = "project_tweety/home_screen_shortcuts"

  private static var pendingType: String?
  private static var live: HomeScreenShortcuts?

  private let channel: FlutterMethodChannel

  private init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = HomeScreenShortcuts(
      channel: FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    )
    instance.channel.setMethodCallHandler(instance.handle)
    registrar.addSceneDelegate(instance)
    live = instance
  }

  static func hold(type: String) {
    pendingType = type
    live?.channel.invokeMethod("shortcutPending", arguments: nil)
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

    HomeScreenShortcuts.hold(type: String(shortcutItem.type.dropFirst(prefix.count)))
    return true
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "takePendingShortcut":
      result(HomeScreenShortcuts.pendingType)
      HomeScreenShortcuts.pendingType = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
