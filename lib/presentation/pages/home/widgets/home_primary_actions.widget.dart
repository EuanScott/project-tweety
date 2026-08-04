part of '../home.page.dart';

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions();

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final useVerticalLayout = textScaleFactor >= 1.4;

    final cancelButton = AppButton.secondary(
      onPressed: () {
        context.read<HomeBloc>().add(
          const HomeActionPressed(HomeAction.cancel),
        );
      },
      child: const Text('Cancel', textAlign: TextAlign.center),
    );
    final nextButton = AppButton.primary(
      onPressed: () {
        context.read<HomeBloc>().add(const HomeActionPressed(HomeAction.next));
      },
      child: const Text('Next', textAlign: TextAlign.center),
    );

    if (useVerticalLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [cancelButton, const SizedBox(height: 12), nextButton],
      );
    }

    return Row(
      children: [
        Expanded(child: cancelButton),
        const SizedBox(width: 16),
        Expanded(child: nextButton),
      ],
    );
  }
}
