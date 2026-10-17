/// What a page is, which decides how its title is shown.
///
/// The values express app intent. Platform-specific widgets decide how that
/// intent maps to Material or Cupertino chrome.
enum PageKind {
  /// A page to browse and come back to, such as a tab, a list or a settings
  /// list. It shows a large title that moves into the toolbar on scroll.
  display,

  /// A [display] page whose large title stays in place, for a page that must
  /// not scroll its header, such as a split view of two panes.
  displayFixed,

  /// A page about one thing, such as one item's details, an edit form or a
  /// status message. It shows its title in the toolbar.
  detail,
}
