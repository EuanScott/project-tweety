import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/widgets/app_modal.dart';

void main() {
  group('AppModal', () {
    group('.page', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.page)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.page)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('close-with-true'));
        await tester.pumpAndSettle();

        expect(find.text('result:true'), findsOneWidget);
      });

      testWidgets('applies the provided border radius', (tester) async {
        const radius = Radius.circular(24);

        await tester.pumpWidget(
          const _TestApp(
            home: _ModalLauncher(
              variant: _ModalVariant.page,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
              ),
            ),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );
        final shape = bottomSheet.shape as RoundedRectangleBorder;

        expect(
          shape.borderRadius,
          const BorderRadius.only(topLeft: radius, topRight: radius),
        );
      });

      testWidgets(
        'applies a max height constraint when maxHeightFactor is provided',
            (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 800),
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                maxHeightFactor: 0.5,
              ),
            ),
          );

          await tester.tap(find.text('open-modal'));
          await tester.pumpAndSettle();

          const expectedMaxHeight = 800 * 0.5;

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );

          expect(bottomSheet.constraints, isNotNull);
          expect(bottomSheet.constraints!.maxHeight, expectedMaxHeight);
        },
      );

      testWidgets('shows the drag handle when showDragHandle is true', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(
            home: _ModalLauncher(
              variant: _ModalVariant.page,
              showDragHandle: true,
            ),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );
        expect(bottomSheet.showDragHandle, isTrue);
      });

      testWidgets('disables system back dismissal when canPop is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(
            home: _ResultHarness(variant: _ModalVariant.page, canPop: false),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
        expect(find.text('result:none'), findsOneWidget);
      });
    });

    group('.compact', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.compact)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets(
        'passes showDragHandle as false when the caller requests it',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              home: _ModalLauncher(variant: _ModalVariant.compact),
            ),
          );

          await tester.tap(find.text('open-modal'));
          await tester.pumpAndSettle();

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );
          expect(bottomSheet.showDragHandle, isFalse);
        },
      );

      testWidgets('defaults showDragHandle to true', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _CompactDefaultLauncher()),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );
        expect(bottomSheet.showDragHandle, isTrue);
      });

      testWidgets('respects maxHeightFactor when provided', (tester) async {
        await tester.pumpWidget(
          const _TestApp(
            mediaQuerySize: Size(400, 1000),
            home: _ModalLauncher(
              variant: _ModalVariant.compact,
              maxHeightFactor: 0.35,
            ),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        const expectedMaxHeight = 1000 * 0.35;

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );

        expect(bottomSheet.constraints, isNotNull);
        expect(bottomSheet.constraints!.maxHeight, expectedMaxHeight);
      });

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.compact)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('close-with-true'));
        await tester.pumpAndSettle();

        expect(find.text('result:true'), findsOneWidget);
      });
    });

    group('.blocking', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.blocking)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('is not dismissed by tapping outside the modal', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.blocking)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.blocking)),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('close-with-false'));
        await tester.pumpAndSettle();

        expect(find.text('result:false'), findsOneWidget);
      });

      testWidgets('disables system back dismissal when canPop is false', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(
            home: _ResultHarness(
              variant: _ModalVariant.blocking,
              canPop: false,
            ),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('modal-child'), findsOneWidget);
        expect(find.text('result:none'), findsOneWidget);
      });

      testWidgets('uses the root navigator when useRootNavigator is true', (
        tester,
      ) async {
        final rootObserver = _TestNavigatorObserver();
        final nestedObserver = _TestNavigatorObserver();

        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [rootObserver],
            home: Navigator(
              observers: [nestedObserver],
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => const _NestedNavigatorHarness(
                  variant: _ModalVariant.blocking,
                  useRootNavigator: true,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open-modal'));
        await tester.pumpAndSettle();

        expect(rootObserver.pushedRoutes.length, greaterThan(0));
      });
    });

    group('widget build', () {
      testWidgets('renders child inside AppModal widget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: AppModal(child: Text('standalone-child'))),
          ),
        );

        expect(find.text('standalone-child'), findsOneWidget);
      });
    });
  });
}

enum _ModalVariant { page, compact, blocking }

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.home,
    this.mediaQuerySize = const Size(400, 800),
  });

  final Widget home;
  final Size mediaQuerySize;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: mediaQuerySize),
      child: MaterialApp(home: Scaffold(body: home)),
    );
  }
}

class _ModalLauncher extends StatelessWidget {
  const _ModalLauncher({
    required this.variant,
    this.borderRadius,
    this.canPop = true,
    this.maxHeightFactor,
    this.showDragHandle,
    this.useSafeArea,
    this.useRootNavigator = false,
  });

  final _ModalVariant variant;
  final BorderRadiusGeometry? borderRadius;
  final bool canPop;
  final double? maxHeightFactor;
  final bool? showDragHandle;
  final bool? useSafeArea;
  final bool useRootNavigator;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => _open(context),
        child: const Text('open-modal'),
      ),
    );
  }

  Future<void> _open(BuildContext context) {
    switch (variant) {
      case _ModalVariant.page:
        return AppModal.page<void>(
          context: context,
          child: const _ModalContent(),
          borderRadius: borderRadius ?? AppModal.defaultBorderRadius,
          canPop: canPop,
          maxHeightFactor: maxHeightFactor ?? AppModal.standardMaxHeightFactor,
          showDragHandle: showDragHandle ?? true,
          useSafeArea: useSafeArea ?? true,
        );
      case _ModalVariant.compact:
        return AppModal.compact<void>(
          context: context,
          child: const _ModalContent(),
          borderRadius: borderRadius ?? AppModal.defaultBorderRadius,
          canPop: canPop,
          maxHeightFactor: maxHeightFactor,
          showDragHandle: showDragHandle ?? false,
          useSafeArea: useSafeArea ?? false,
        );
      case _ModalVariant.blocking:
        return AppModal.blocking<void>(
          context: context,
          child: const _ModalContent(),
          borderRadius: borderRadius ?? AppModal.defaultBorderRadius,
          canPop: canPop,
          maxHeightFactor: maxHeightFactor,
          useSafeArea: useSafeArea ?? true,
          useRootNavigator: useRootNavigator,
        );
    }
  }
}

class _CompactDefaultLauncher extends StatelessWidget {
  const _CompactDefaultLauncher();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          AppModal.compact<void>(
            context: context,
            child: const _ModalContent(),
          );
        },
        child: const Text('open-modal'),
      ),
    );
  }
}

class _ResultHarness extends StatefulWidget {
  const _ResultHarness({
    required this.variant,
    this.canPop = true,
    this.useRootNavigator = false,
  });

  final _ModalVariant variant;
  final bool canPop;
  final bool useRootNavigator;

  @override
  State<_ResultHarness> createState() => _ResultHarnessState();
}

class _ResultHarnessState extends State<_ResultHarness> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final value = await _open(context);
            setState(() {
              result = value;
            });
          },
          child: const Text('open-modal'),
        ),
        Text('result:${result?.toString() ?? 'none'}'),
      ],
    );
  }

  Future<bool?> _open(BuildContext context) {
    switch (widget.variant) {
      case _ModalVariant.page:
        return AppModal.page<bool>(
          context: context,
          canPop: widget.canPop,
          child: const _ResultModalContent(),
        );
      case _ModalVariant.compact:
        return AppModal.compact<bool>(
          context: context,
          canPop: widget.canPop,
          child: const _ResultModalContent(),
        );
      case _ModalVariant.blocking:
        return AppModal.blocking<bool>(
          context: context,
          canPop: widget.canPop,
          useRootNavigator: widget.useRootNavigator,
          child: const _ResultModalContent(),
        );
    }
  }
}

class _NestedNavigatorHarness extends StatelessWidget {
  const _NestedNavigatorHarness({
    required this.variant,
    required this.useRootNavigator,
  });

  final _ModalVariant variant;
  final bool useRootNavigator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            if (variant == _ModalVariant.blocking) {
              AppModal.blocking<void>(
                context: context,
                useRootNavigator: useRootNavigator,
                child: const _ModalContent(),
              );
            }
          },
          child: const Text('open-modal'),
        ),
      ),
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('modal-child'));
  }
}

class _ResultModalContent extends StatelessWidget {
  const _ResultModalContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('modal-child'),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('close-with-true'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('close-with-false'),
        ),
      ],
    );
  }
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
