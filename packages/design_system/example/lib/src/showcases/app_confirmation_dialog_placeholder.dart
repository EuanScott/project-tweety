import 'package:material_ui/material_ui.dart';

/// Placeholder for `AppConfirmationDialog`.
///
/// It's a bare `showDialog`/`showCupertinoDialog`-invoking function with no
/// embeddable render, so it can't be shown in the gallery's two-pane
/// comparison layout the way every other showcase is. Comparing it needs
/// per-pane isolation (e.g. a nested `Navigator` per pane) so triggering the
/// dialog in one pane doesn't cover the other — deferred, see the component
/// gallery spec's Out of Scope list.
class const AppConfirmationDialogPlaceholder({super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: .all(24),
        child: Text(
          'todo: implement this\n\n'
          'AppConfirmationDialog has no embeddable render — comparing it '
          'in both panes at once needs per-pane isolation, which is '
          'deferred.',
          textAlign: .center,
        ),
      ),
    );
  }
}
