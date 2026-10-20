import AppIntents

/// Opens the app on the log entry editor. Shared by the app and the control
/// extension; iOS runs perform() in the app process.
struct CreateLogIntent: AppIntent {
  static let title: LocalizedStringResource = "New log"
  static let openAppWhenRun = true
  static let authenticationPolicy: IntentAuthenticationPolicy = .requiresLocalDeviceAuthentication

  @available(iOS 26.0, *)
  static let supportedModes: IntentModes = .foreground

  init() {}

  @MainActor
  func perform() async throws -> some IntentResult {
    #if !CONTROLS_EXTENSION
    HomeScreenShortcuts.hold(type: "createLog")
    #endif
    return .result()
  }
}
