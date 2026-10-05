part of '../home.page.dart';

/// The buttons and modals this playground app shows off.
class _HomeShowcase extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const .symmetric(vertical: 16),
      children: [
        // TODO: Better usecase widgets for things like buttons so that the robots doesn't invent anything
        // TODO: Maybe make list of implemented widgets to view, rather than everything on this page (UI library vibes)
        const _PrimaryActions(),
        const SizedBox(height: 16),
        AppButton.primary(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.primary),
            );
          },
          child: const Text('Button'),
        ),
        const SizedBox(height: 16),
        AppButton.secondary(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.secondary),
            );
          },
          child: const Text('Button'),
        ),
        const SizedBox(height: 16),
        AppButton.text(
          onPressed: () {
            context.read<HomeBloc>().add(
              const HomeActionPressed(HomeAction.back),
            );
          },
          child: const Text('Back'),
        ),
        const SizedBox(height: 32),
        Text('Modals', style: theme.textTheme.headlineSmall),
        AppButton.text(
          onPressed: () {
            unawaited(
              context.showAppModal(
                const Center(child: Text('Modal content')),
              ),
            );
          },
          child: const Text('Context Modal'),
        ),
        AppButton.text(
          onPressed: () {
            unawaited(
              AppModal.page<bool>(
                context: context,
                child: const Center(child: Text('Modal content')),
              ),
            );
          },
          child: const Text('Page Modal'),
        ),
        AppButton.text(
          onPressed: () {
            unawaited(
              AppModal.blocking<bool>(
                context: context,
                child: Center(
                  child: Builder(
                    builder: (modalContext) => AppButton.text(
                      onPressed: () => Navigator.of(modalContext).pop(true),
                      child: const Text('Close Modal'),
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Text('Blocking Modal'),
        ),
        AppButton.text(
          onPressed: () async {
            await AppModal.compact<bool>(
              context: context,
              maxHeightFactor: 0.35,
              child: const Center(child: Text('Modal content')),
            );
          },
          child: const Text('Compact Modal'),
        ),
        AppButton.text(
          onPressed: () async {
            final result = await WebviewModal.show(
              context,
              'https://euanscott.github.io/tester.html',
            );

            if (result != null) {
              log('User result: $result');
            }
          },
          child: const Text('Blocking Modal'),
        ),
      ],
    );
  }
}
