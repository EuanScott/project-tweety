import UIKit
import Flutter

@objc class SceneDelegate: FlutterSceneDelegate {
  private let channelName = "project_tweety/system_text_settings"

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    registerSystemTextSettingsChannel()
  }

  private func registerSystemTextSettingsChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "openTextSettings":
        result(self.openTextSettings())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func openTextSettings() -> Bool {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      return false
    }

    guard UIApplication.shared.canOpenURL(url) else {
      return false
    }

    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    return true
  }
}
