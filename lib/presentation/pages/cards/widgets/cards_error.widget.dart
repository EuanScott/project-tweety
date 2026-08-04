part of '../cards.page.dart';

class _CardsError extends StatelessWidget {
  const _CardsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            AppButton.primary(
              onPressed: () {
                context.read<CardsBloc>().add(const CardsStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
