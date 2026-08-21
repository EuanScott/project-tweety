part of '../card_details.page.dart';

class const _CardDetailsMessage({
  required final String title,
  required final String description,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: .center,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: .center),
          ],
        ),
      ),
    );
  }
}
