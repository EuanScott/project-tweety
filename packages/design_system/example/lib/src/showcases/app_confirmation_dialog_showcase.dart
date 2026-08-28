import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

/// Showcase for `AppConfirmationDialog`, rendered as a static preview.
///
/// `showAppConfirmationDialog` (`app_confirmation_dialog.dart`) is a bare
/// `showDialog`/`showCupertinoDialog`-invoking function with no embeddable
/// render, and comparing a real triggered dialog in both panes at once
/// needs per-pane isolation (see the queued backlog item for that). This
/// mirrors the same dummy copy and the same `CupertinoAlertDialog`/
/// `AlertDialog` widget classes that function builds internally, but
/// renders them directly as static content instead of through a route, so
/// there's no interaction to isolate — the actions are wired to [noop].
class const AppConfirmationDialogShowcase({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        const ShowcaseControls(),
        Expanded(
          child: ComparisonView(contentBuilder: _buildDialog),
        ),
      ],
    );
  }

  Widget _buildDialog(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return const CupertinoAlertDialog(
        title: Text('Delete card?'),
        content: Text("This action can't be undone."),
        actions: [
          CupertinoDialogAction(onPressed: noop, child: Text('Cancel')),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: noop,
            child: Text('Delete'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Delete card?'),
      content: const Text("This action can't be undone."),
      actions: [
        const TextButton(onPressed: noop, child: Text('Cancel')),
        TextButton(
          onPressed: noop,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
