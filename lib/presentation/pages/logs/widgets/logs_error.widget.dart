part of '../logs.page.dart';

class const _LogsError({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(message, textAlign: .center),
            const SizedBox(height: 12),
            AppButton.primary(
              onPressed: () {
                context.read<LogsBloc>().add(const LogsStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
