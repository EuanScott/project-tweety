part of '../log_entry_details.page.dart';

/// A failure message under a log entry's content, lined up with the page's
/// fields and buttons.
class const _LogEntryDetailsError(final String message)
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
