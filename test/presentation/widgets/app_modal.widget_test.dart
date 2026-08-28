import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/widgets/app_modal.dart';

const _modalTransitionDuration = Duration(milliseconds: 250);

Future<void> _tapAndFinishTransition(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(_modalTransitionDuration);
}

Future<void> _handlePopRouteAndFinishTransition(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pump();
  await tester.pump(_modalTransitionDuration);
}

void main() {
  group('AppModal', () {
    group('.page', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.page)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.page)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));
        await _tapAndFinishTransition(tester, find.text('close-with-true'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));

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

          await _tapAndFinishTransition(tester, find.text('open-modal'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));
        await _handlePopRouteAndFinishTransition(tester);

        expect(find.text('modal-child'), findsOneWidget);
        expect(find.text('result:none'), findsOneWidget);
      });

      testWidgets(
        'fills to maxHeightFactor even with short content by default',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 800),
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );
          const expectedHeight = 800 * AppModal.standardMaxHeightFactor;

          expect(bottomSheet.constraints!.minHeight, expectedHeight);
          expect(bottomSheet.constraints!.maxHeight, expectedHeight);
        },
      );

      testWidgets(
        'shrink-wraps short content when expandToMaxHeight is false',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                expandToMaxHeight: false,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );

          expect(bottomSheet.constraints!.minHeight, 0);
        },
      );
    });

    group('.compact', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.compact)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

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

          await _tapAndFinishTransition(tester, find.text('open-modal'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        const expectedMaxHeight = 1000 * 0.35;

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );

        expect(bottomSheet.constraints, isNotNull);
        expect(bottomSheet.constraints!.maxHeight, expectedMaxHeight);
      });

      testWidgets(
        'fills to maxHeightFactor even with short content by default',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 1000),
              home: _ModalLauncher(
                variant: _ModalVariant.compact,
                maxHeightFactor: 0.35,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          const expectedHeight = 1000 * 0.35;

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );

          expect(bottomSheet.constraints!.minHeight, expectedHeight);
          expect(bottomSheet.constraints!.maxHeight, expectedHeight);
        },
      );

      testWidgets(
        'shrink-wraps short content when expandToMaxHeight is false',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 1000),
              home: _ModalLauncher(
                variant: _ModalVariant.compact,
                maxHeightFactor: 0.35,
                expandToMaxHeight: false,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );

          expect(bottomSheet.constraints!.minHeight, 0);
        },
      );

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.compact)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));
        await _tapAndFinishTransition(tester, find.text('close-with-true'));

        expect(find.text('result:true'), findsOneWidget);
      });
    });

    group('.blocking', () {
      testWidgets('renders the provided child', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.blocking)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('is not dismissed by tapping outside the modal', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.blocking)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
        await tester.pump(_modalTransitionDuration);

        expect(find.text('modal-child'), findsOneWidget);
      });

      testWidgets('returns the value passed to Navigator.pop', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ResultHarness(variant: _ModalVariant.blocking)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));
        await _tapAndFinishTransition(tester, find.text('close-with-false'));

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));
        await _handlePopRouteAndFinishTransition(tester);

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

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(rootObserver.pushedRoutes.length, greaterThan(0));
      });

      testWidgets(
        'fills to standardMaxHeightFactor even with short content',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 800),
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );
          const expectedHeight = 800 * AppModal.standardMaxHeightFactor;

          expect(bottomSheet.constraints!.minHeight, expectedHeight);
          expect(bottomSheet.constraints!.maxHeight, expectedHeight);
        },
      );
    });

    group('close button', () {
      testWidgets('does not show a close button on .page', (tester) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.page)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('does not show a close button on .compact', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(home: _ModalLauncher(variant: _ModalVariant.compact)),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(find.byIcon(Icons.close), findsNothing);
      });

      testWidgets('never shows a close button on .blocking', (tester) async {
        await tester.pumpWidget(
          const _TestApp(
            home: _ModalLauncher(variant: _ModalVariant.blocking),
          ),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        expect(find.byIcon(Icons.close), findsNothing);
      });
    });

    group('default height', () {
      testWidgets('.page defaults to standardMaxHeightFactor of the screen', (
        tester,
      ) async {
        await tester.pumpWidget(
          const _TestApp(
            mediaQuerySize: Size(400, 800),
            home: _ModalLauncher(variant: _ModalVariant.page),
          ),
        );

        await _tapAndFinishTransition(tester, find.text('open-modal'));

        final bottomSheet = tester.widget<BottomSheet>(
          find.byType(BottomSheet),
        );

        expect(
          bottomSheet.constraints!.maxHeight,
          800 * AppModal.standardMaxHeightFactor,
        );
      });

      testWidgets(
        '.blocking defaults to standardMaxHeightFactor of the screen',
        (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: Size(400, 800),
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final bottomSheet = tester.widget<BottomSheet>(
            find.byType(BottomSheet),
          );

          expect(
            bottomSheet.constraints!.maxHeight,
            800 * AppModal.standardMaxHeightFactor,
          );
        },
      );
    });

    group('cupertino', () {
      group('text styling', () {
        testWidgets(
          'provides a Material ancestor so child Text does not fall back '
          "to Flutter's missing-Material debug style",
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                home: _ModalLauncher(variant: _ModalVariant.page),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            final materialAncestor = find.ancestor(
              of: find.text('modal-child'),
              matching: find.byType(Material),
            );

            expect(materialAncestor, findsWidgets);
          },
        );

        testWidgets(
          'resolves modal-child text to a themed color, not the debug '
          'fallback red',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                home: _ModalLauncher(variant: _ModalVariant.page),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            final defaultTextStyle = tester.widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text('modal-child'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            );

            expect(defaultTextStyle.style.color, isNot(const Color(0xD0FF0000)));
          },
        );
      });

      group('close button', () {
        testWidgets('shows a close button by default on .page', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsOneWidget);
        });

        testWidgets('shows a close button by default on .compact', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(variant: _ModalVariant.compact),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsOneWidget);
        });

        testWidgets('never shows a close button on .blocking', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsNothing);
        });

        testWidgets('hides the close button when showCloseButton is false', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                showCloseButton: false,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsNothing);
        });

        testWidgets('tapping it pops the modal with a null result on .page', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ResultHarness(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _tapAndFinishTransition(tester, find.byIcon(Icons.close));

          expect(find.text('result:none'), findsOneWidget);
        });
      });

      group('default height', () {
        testWidgets(
          '.page defaults to standardMaxHeightFactor of the screen',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                mediaQuerySize: Size(400, 800),
                home: _ModalLauncher(variant: _ModalVariant.page),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            final container = tester.widget<Container>(
              find.byType(Container),
            );

            expect(
              container.constraints!.maxHeight,
              800 * AppModal.standardMaxHeightFactor,
            );
          },
        );

        testWidgets(
          '.blocking defaults to standardMaxHeightFactor of the screen',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                mediaQuerySize: Size(400, 800),
                home: _ModalLauncher(variant: _ModalVariant.blocking),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            final container = tester.widget<Container>(
              find.byType(Container),
            );

            expect(
              container.constraints!.maxHeight,
              800 * AppModal.standardMaxHeightFactor,
            );
          },
        );
      });

      group('.page', () {
        testWidgets('renders the provided child', (tester) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.text('modal-child'), findsOneWidget);
        });

        testWidgets('returns the value passed to Navigator.pop', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ResultHarness(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _tapAndFinishTransition(tester, find.text('close-with-true'));

          expect(find.text('result:true'), findsOneWidget);
        });

        testWidgets('applies the provided border radius', (tester) async {
          const radius = Radius.circular(24);

          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                ),
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));

          expect(
            clipRRect.borderRadius,
            const BorderRadius.only(topLeft: radius, topRight: radius),
          );
        });

        testWidgets(
          'applies a max height constraint when maxHeightFactor is provided',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                mediaQuerySize: Size(400, 800),
                home: _ModalLauncher(
                  variant: _ModalVariant.page,
                  maxHeightFactor: 0.5,
                ),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            const expectedMaxHeight = 800 * 0.5;

            final container = tester.widget<Container>(
              find.byType(Container),
            );

            expect(container.constraints, isNotNull);
            expect(container.constraints!.maxHeight, expectedMaxHeight);
          },
        );

        testWidgets('disables system back dismissal when canPop is false', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ResultHarness(
                variant: _ModalVariant.page,
                canPop: false,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _handlePopRouteAndFinishTransition(tester);

          expect(find.text('modal-child'), findsOneWidget);
          expect(find.text('result:none'), findsOneWidget);
        });
      });

      group('.blocking', () {
        testWidgets(
          'safe-area padding insets content, not the sheet background',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                mediaQuerySize: Size(400, 800),
                viewPaddingBottom: 34,
                home: _ModalLauncher(variant: _ModalVariant.blocking),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            // The background-painting Container/ClipRRect must not sit
            // inside the SafeArea, otherwise the sheet's colored background
            // gets padded away from the true screen edge instead of only
            // the interactive content.
            expect(
              find.ancestor(
                of: find.byType(ClipRRect),
                matching: find.byType(SafeArea),
              ),
              findsNothing,
            );

            // SafeArea must still be present, protecting the content inside
            // the background container.
            expect(
              find.descendant(
                of: find.byType(ClipRRect),
                matching: find.byType(SafeArea),
              ),
              findsOneWidget,
            );
          },
        );

        testWidgets('is not dismissed by tapping outside the modal', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          await tester.tapAt(const Offset(10, 10));
          await tester.pump();
          await tester.pump(_modalTransitionDuration);

          expect(find.text('modal-child'), findsOneWidget);
        });

        testWidgets('returns the value passed to Navigator.pop', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              home: _ResultHarness(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _tapAndFinishTransition(tester, find.text('close-with-false'));

          expect(find.text('result:false'), findsOneWidget);
        });

        testWidgets('uses the root navigator when useRootNavigator is true', (
          tester,
        ) async {
          final rootObserver = _TestNavigatorObserver();
          final nestedObserver = _TestNavigatorObserver();

          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
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

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(rootObserver.pushedRoutes.length, greaterThan(0));
        });
      });
    });

    group('windowed presentation', () {
      const expandedSize = Size(900, 1200);

      group('material', () {
        testWidgets('renders a Dialog instead of a BottomSheet', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byType(BottomSheet), findsNothing);
          expect(find.byType(Dialog), findsOneWidget);
        });

        testWidgets('caps width at windowedMaxWidth on a wide surface', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final constrainedBox = tester.widget<ConstrainedBox>(
            find
                .ancestor(
                  of: find.text('modal-child'),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          );

          expect(
            constrainedBox.constraints.maxWidth,
            AppModal.windowedMaxWidth,
          );
        });

        testWidgets('applies an all-corner border radius', (tester) async {
          const radius = Radius.circular(24);

          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                ),
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final dialog = tester.widget<Dialog>(find.byType(Dialog));
          final shape = dialog.shape as RoundedRectangleBorder;

          expect(shape.borderRadius, const BorderRadius.all(radius));
        });

        testWidgets(
          'applies a max height constraint when maxHeightFactor is provided',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                mediaQuerySize: expandedSize,
                home: _ModalLauncher(
                  variant: _ModalVariant.page,
                  maxHeightFactor: 0.5,
                ),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            const expectedMaxHeight = 1200 * 0.5;

            final constrainedBox = tester.widget<ConstrainedBox>(
              find
                  .ancestor(
                    of: find.text('modal-child'),
                    matching: find.byType(ConstrainedBox),
                  )
                  .first,
            );

            expect(constrainedBox.constraints.maxHeight, expectedMaxHeight);
          },
        );

        testWidgets('shows a close button on .page when showCloseButton is true', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsOneWidget);
        });

        testWidgets('hides the close button when showCloseButton is false', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                showCloseButton: false,
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsNothing);
        });

        testWidgets('never shows a close button on .blocking', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsNothing);
        });

        testWidgets('.blocking is not dismissed by tapping outside', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          await tester.tapAt(const Offset(10, 10));
          await tester.pump();
          await tester.pump(_modalTransitionDuration);

          expect(find.text('modal-child'), findsOneWidget);
        });

        testWidgets('disables system back dismissal when canPop is false', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ResultHarness(variant: _ModalVariant.page, canPop: false),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _handlePopRouteAndFinishTransition(tester);

          expect(find.text('modal-child'), findsOneWidget);
          expect(find.text('result:none'), findsOneWidget);
        });

        testWidgets('returns the value passed to Navigator.pop', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              mediaQuerySize: expandedSize,
              home: _ResultHarness(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _tapAndFinishTransition(tester, find.text('close-with-true'));

          expect(find.text('result:true'), findsOneWidget);
        });

        testWidgets(
          'treats a surface exactly at the breakpoint as windowed',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                mediaQuerySize: Size(600, 1000),
                home: _ModalLauncher(variant: _ModalVariant.page),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            expect(find.byType(BottomSheet), findsNothing);
            expect(find.byType(Dialog), findsOneWidget);
          },
        );

        testWidgets(
          'stays a bottom sheet just below the breakpoint',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                mediaQuerySize: Size(599, 1000),
                home: _ModalLauncher(variant: _ModalVariant.page),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            expect(find.byType(Dialog), findsNothing);
            expect(find.byType(BottomSheet), findsOneWidget);
          },
        );
      });

      group('cupertino', () {
        testWidgets('caps width at windowedMaxWidth on a wide surface', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final container = tester.widget<Container>(
            find.byType(Container),
          );

          expect(container.constraints!.maxWidth, AppModal.windowedMaxWidth);
        });

        testWidgets('applies an all-corner border radius', (tester) async {
          const radius = Radius.circular(24);

          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(
                variant: _ModalVariant.page,
                borderRadius: BorderRadius.only(
                  topLeft: radius,
                  topRight: radius,
                ),
              ),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));

          expect(clipRRect.borderRadius, const BorderRadius.all(radius));
        });

        testWidgets(
          'applies a max height constraint when maxHeightFactor is provided',
          (tester) async {
            await tester.pumpWidget(
              const _TestApp(
                platform: TargetPlatform.iOS,
                mediaQuerySize: expandedSize,
                home: _ModalLauncher(
                  variant: _ModalVariant.page,
                  maxHeightFactor: 0.5,
                ),
              ),
            );

            await _tapAndFinishTransition(tester, find.text('open-modal'));

            const expectedMaxHeight = 1200 * 0.5;

            final container = tester.widget<Container>(
              find.byType(Container),
            );

            expect(container.constraints!.maxHeight, expectedMaxHeight);
          },
        );

        testWidgets('shows a close button on .page by default', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsOneWidget);
        });

        testWidgets('never shows a close button on .blocking', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          expect(find.byIcon(Icons.close), findsNothing);
        });

        testWidgets('.blocking is not dismissed by tapping outside', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ModalLauncher(variant: _ModalVariant.blocking),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));

          await tester.tapAt(const Offset(10, 10));
          await tester.pump();
          await tester.pump(_modalTransitionDuration);

          expect(find.text('modal-child'), findsOneWidget);
        });

        testWidgets('returns the value passed to Navigator.pop', (
          tester,
        ) async {
          await tester.pumpWidget(
            const _TestApp(
              platform: TargetPlatform.iOS,
              mediaQuerySize: expandedSize,
              home: _ResultHarness(variant: _ModalVariant.page),
            ),
          );

          await _tapAndFinishTransition(tester, find.text('open-modal'));
          await _tapAndFinishTransition(tester, find.text('close-with-true'));

          expect(find.text('result:true'), findsOneWidget);
        });
      });
    });
  });
}

enum _ModalVariant { page, compact, blocking }

class _TestApp extends StatelessWidget {
  const new({
    required this.home,
    this.mediaQuerySize = const Size(400, 800),
    this.platform = TargetPlatform.android,
    this.viewPaddingBottom = 0,
  });

  final Widget home;
  final Size mediaQuerySize;
  final TargetPlatform platform;
  final double viewPaddingBottom;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(
        size: mediaQuerySize,
        disableAnimations: true,
        padding: EdgeInsets.only(bottom: viewPaddingBottom),
      ),
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(body: home),
      ),
    );
  }
}

class _ModalLauncher extends StatelessWidget {
  const new({
    required this.variant,
    this.borderRadius,
    this.maxHeightFactor,
    this.showDragHandle,
    this.showCloseButton = true,
    this.expandToMaxHeight,
  });

  final _ModalVariant variant;
  final BorderRadiusGeometry? borderRadius;
  final double? maxHeightFactor;
  final bool? showDragHandle;
  final bool showCloseButton;
  final bool? expandToMaxHeight;

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
          borderRadius: borderRadius ?? DesignSystemBottomSheetTheme.radius,
          maxHeightFactor: maxHeightFactor ?? AppModal.standardMaxHeightFactor,
          showDragHandle: showDragHandle ?? true,
          showCloseButton: showCloseButton,
          expandToMaxHeight: expandToMaxHeight ?? true,
        );
      case _ModalVariant.compact:
        return AppModal.compact<void>(
          context: context,
          child: const _ModalContent(),
          borderRadius: borderRadius ?? DesignSystemBottomSheetTheme.radius,
          maxHeightFactor: maxHeightFactor,
          showDragHandle: showDragHandle ?? false,
          showCloseButton: showCloseButton,
          expandToMaxHeight: expandToMaxHeight ?? true,
        );
      case _ModalVariant.blocking:
        return AppModal.blocking<void>(
          context: context,
          child: const _ModalContent(),
          borderRadius: borderRadius ?? DesignSystemBottomSheetTheme.radius,
          maxHeightFactor: maxHeightFactor ?? AppModal.standardMaxHeightFactor,
        );
    }
  }
}

class _CompactDefaultLauncher extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          unawaited(
            AppModal.compact<void>(
              context: context,
              child: const _ModalContent(),
            ),
          );
        },
        child: const Text('open-modal'),
      ),
    );
  }
}

class _ResultHarness extends StatefulWidget {
  const new({required this.variant, this.canPop = true});

  final _ModalVariant variant;
  final bool canPop;

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
          child: const _ResultModalContent(),
        );
    }
  }
}

class _NestedNavigatorHarness extends StatelessWidget {
  const new({
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
              unawaited(
                AppModal.blocking<void>(
                  context: context,
                  useRootNavigator: useRootNavigator,
                  child: const _ModalContent(),
                ),
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
  const new();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('modal-child'));
  }
}

class _ResultModalContent extends StatelessWidget {
  const new();

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
