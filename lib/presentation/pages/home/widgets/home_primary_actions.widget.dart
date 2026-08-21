part of '../home.page.dart';

class const _PrimaryActions() extends StatelessWidget {
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
      child: const Text('Cancel', textAlign: .center),
    );
    final nextButton = AppButton.primary(
      onPressed: () {
        context.read<HomeBloc>().add(const HomeActionPressed(HomeAction.next));
      },
      child: const Text('Next', textAlign: .center),
    );

    if (useVerticalLayout) {
      return Column(
        crossAxisAlignment: .stretch,
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
