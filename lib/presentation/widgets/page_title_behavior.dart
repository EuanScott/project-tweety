/// Describes how a shared page title should be presented.
///
/// The values express app intent. Platform-specific widgets decide how that
/// intent maps to Material or Cupertino chrome.
enum PageTitleBehavior {
  /// Render the platform's standard app/navigation bar title.
  standard,

  /// Render a large title where the platform supports it.
  large,

  /// Render a large title without allowing header-only collapse gestures.
  largeStatic;

  /// Whether Cupertino chrome should render a large title.
  bool get usesLargeCupertinoTitle {
    return this == .large || this == .largeStatic;
  }

  /// Whether large-title chrome can collapse through scroll gestures.
  bool get allowsCupertinoCollapse => this != .largeStatic;
}
