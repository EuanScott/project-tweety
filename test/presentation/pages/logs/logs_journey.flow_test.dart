import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/log_entry/logs.repository.dart'
    as logs_repository;
import 'package:project_tweety/presentation/navigation/app_routes.constants.dart';

import '../../../support/app_harness.dart';
import '../../../support/fake_logs_repository.dart';

const _phone = Size(400, 800);
const _landscapeTablet = Size(1194, 834);
const _cardOneDetails = '${AppRoutes.logsDetailFullPathPrefix}card-1';

void main() {
  group('Logs journey', () {
    useAppHarness();

    group('details', () {
      testWidgets('show the log entry and its ID in grouped sections on iOS', (
        WidgetTester tester,
      ) async {
        await pumpApp(
          tester,
          initialLocation: _cardOneDetails,
          platform: TargetPlatform.iOS,
        );

        expect(find.byType(CupertinoListSection), findsNWidgets(2));
        expect(_inside(CupertinoListSection, 'Card Title 1'), findsOneWidget);
        expect(find.text('ID'), findsOneWidget);
        expect(_inside(CupertinoListSection, 'card-1'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      });

      testWidgets('show the log entry and its ID in one card on Android', (
        WidgetTester tester,
      ) async {
        await pumpApp(
          tester,
          initialLocation: _cardOneDetails,
          platform: TargetPlatform.android,
        );

        expect(find.byType(Card), findsOneWidget);
        for (final text in ['Card Title 1', 'ID', 'card-1']) {
          expect(_inside(Card, text), findsOneWidget, reason: text);
        }
      });

      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        testWidgets('offer Delete entry in error red, calmer than Edit entry, '
            'and confirm first on ${platform.name}', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          final error = Theme.of(tester.element(find.text('Delete entry')))
              .colorScheme
              .error;
          expect(_textColor(tester, 'Delete entry'), error);
          if (platform == TargetPlatform.android) {
            expect(
              find.ancestor(
                of: find.text('Delete entry'),
                matching: find.byType(OutlinedButton),
              ),
              findsOneWidget,
            );
          }

          await tester.tap(find.text('Delete entry'));
          await tester.pumpAndSettle();

          expect(find.text('Delete entry?'), findsOneWidget);
        });
      }

      testWidgets('mark a log entry created on this device as New', (
        WidgetTester tester,
      ) async {
        replaceLogsRepository(
          FakeLogsRepository()
            ..syncSummary = const logs_repository.LogsSyncSummary(
              pendingChanges: {
                'card-1': logs_repository.PendingLogEntryChange.created,
              },
            ),
        );

        await pumpApp(tester, initialLocation: _cardOneDetails);

        expect(find.text('New'), findsOneWidget);
      });

      testWidgets('show no marker for a synced log entry', (
        WidgetTester tester,
      ) async {
        replaceLogsRepository(
          FakeLogsRepository()
            ..syncSummary = const logs_repository.LogsSyncSummary(
              pendingChanges: {
                'card-2': logs_repository.PendingLogEntryChange.updated,
              },
            ),
        );

        await pumpApp(tester, initialLocation: _cardOneDetails);

        expect(find.text('Edited'), findsNothing);
        expect(find.text('New'), findsNothing);
      });

      testWidgets('clear the marker with the list after a sync', (
        WidgetTester tester,
      ) async {
        replaceLogsRepository(
          FakeLogsRepository()
            ..syncSummary = const logs_repository.LogsSyncSummary(
              pendingChanges: {
                'card-1': logs_repository.PendingLogEntryChange.updated,
              },
            )
            ..summaryAfterSync = const logs_repository.LogsSyncSummary()
            ..syncResult = const logs_repository.LogsSyncResult(
              changeCount: 1,
              savedCount: 1,
            ),
        );

        await pumpApp(
          tester,
          surfaceSize: _landscapeTablet,
          initialLocation: _cardOneDetails,
        );

        expect(find.text('Edited'), findsNWidgets(2));

        await tester.tap(find.widgetWithText(AppButton, 'Sync'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Edited'), findsNothing);
      });
    });

    group('headers', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        testWidgets('name each phone screen once, in the bar, on '
            '${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          expect(_inBar('Entry details'), findsOneWidget);
          expect(find.text('Entry details'), findsOneWidget);

          await tester.tap(find.text('Edit entry'));
          await tester.pumpAndSettle();

          expect(_inBar('Edit entry'), findsOneWidget);
          expect(find.text('Edit entry'), findsOneWidget);
          expect(find.text('Entry details'), findsNothing);
        });

        testWidgets('name the phone editor for a new log entry once, in the '
            'bar, on ${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            initialLocation: AppRoutes.logsNewPath,
            platform: platform,
          );

          expect(_inBar('New entry'), findsOneWidget);
          expect(find.text('New entry'), findsOneWidget);
        });

        testWidgets('name the right pane without a back button and keep Logs '
            'in the bar on ${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: _landscapeTablet,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          expect(_inBar('Logs'), findsOneWidget);
          expect(_inBar('Entry details'), findsNothing);
          expect(_inside(AppPaneHeader, 'Entry details'), findsOneWidget);
          expect(find.byTooltip('Back'), findsNothing);
          expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);

          await tester.tap(find.text('Edit entry'));
          await tester.pumpAndSettle();

          expect(_inside(AppPaneHeader, 'Edit entry'), findsOneWidget);
        });

        testWidgets('name the right pane New entry while creating on '
            '${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: _landscapeTablet,
            initialLocation: AppRoutes.logsNewPath,
            platform: platform,
          );

          expect(_inside(AppPaneHeader, 'New entry'), findsOneWidget);
          expect(find.byTooltip('Back'), findsNothing);
        });
      }

      testWidgets('show no pane header on a phone', (
        WidgetTester tester,
      ) async {
        await pumpApp(tester, initialLocation: _cardOneDetails);

        expect(find.byType(AppPaneHeader), findsNothing);
      });
    });

    group('right pane', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        testWidgets('returns to the details after Save changes, with the list '
            'still in view on ${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: _landscapeTablet,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          await tester.tap(find.text('Edit entry'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(AppTextField).first, 'New name');
          await tester.tap(find.text('Save changes'));
          await tester.pumpAndSettle();

          expect(_inside(AppPaneHeader, 'Entry details'), findsOneWidget);
          expect(find.text('New name'), findsNWidgets(2));
          expect(find.text('Card Title 2'), findsOneWidget);
        });

        testWidgets('returns to the unchanged details after Cancel on '
            '${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: _landscapeTablet,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          await tester.tap(find.text('Edit entry'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          expect(_inside(AppPaneHeader, 'Entry details'), findsOneWidget);
          expect(find.text('Card Title 1'), findsNWidgets(2));
        });

        testWidgets('shows the new log entry details after Create entry '
            'on ${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: _landscapeTablet,
            initialLocation: AppRoutes.logsNewPath,
            platform: platform,
          );

          await tester.enterText(find.byType(AppTextField).first, 'New title');
          await tester.enterText(
            find.byType(AppTextField).last,
            'New description',
          );
          await tester.tap(find.widgetWithText(AppButton, 'Create entry'));
          await tester.pumpAndSettle();

          expect(_inside(AppPaneHeader, 'Entry details'), findsOneWidget);
          expect(find.text('New title'), findsNWidgets(2));
          expect(find.text('Card Title 1'), findsOneWidget);
        });
      }
    });

    group('button width', () {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        for (final (name, size) in [
          ('a landscape tablet', _landscapeTablet),
          ('a wide window', const Size(1600, 1000)),
        ]) {
          testWidgets('is no wider than 480 and centred in the right pane on '
              '$name on ${platform.name}', (WidgetTester tester) async {
            await pumpApp(
              tester,
              surfaceSize: size,
              initialLocation: _cardOneDetails,
              platform: platform,
            );

            final button = tester.getRect(
              find.widgetWithText(AppButton, 'Edit entry'),
            );
            final pane = tester.getRect(find.byType(AppPaneHeader));

            expect(button.width, lessThanOrEqualTo(480));
            expect(button.center.dx, moreOrLessEquals(pane.center.dx));
          });
        }

        testWidgets('stops at 480 in a right pane wider than that on '
            '${platform.name}', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: const Size(1600, 1000),
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          expect(
            tester.getSize(find.widgetWithText(AppButton, 'Edit entry')).width,
            480,
          );
        });

        testWidgets('fills the width on a phone on ${platform.name}', (
          WidgetTester tester,
        ) async {
          await pumpApp(
            tester,
            initialLocation: _cardOneDetails,
            platform: platform,
          );

          final button = tester.getRect(
            find.widgetWithText(AppButton, 'Edit entry'),
          );

          expect(button.width, _phone.width - 32);
        });
      }
    });

    group('editor', () {
      for (final (name, size) in [
        ('a phone', _phone),
        ('a landscape tablet', _landscapeTablet),
      ]) {
        testWidgets('labels the fields in upper case above grouped rows on iOS '
            'on $name', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: size,
            initialLocation: AppRoutes.logsNewPath,
            platform: TargetPlatform.iOS,
          );

          expect(find.text('TITLE'), findsOneWidget);
          expect(find.text('DESCRIPTION'), findsOneWidget);
          expect(find.text('Title'), findsNothing);
          expect(
            tester.getRect(find.text('TITLE')).bottom,
            lessThanOrEqualTo(
              tester.getRect(find.byType(AppTextField).first).center.dy,
            ),
          );
        });

        testWidgets('labels the fields with floating Material labels on '
            'Android on $name', (WidgetTester tester) async {
          await pumpApp(
            tester,
            surfaceSize: size,
            initialLocation: AppRoutes.logsNewPath,
            platform: TargetPlatform.android,
          );

          expect(find.text('Title'), findsOneWidget);
          expect(find.text('Description'), findsOneWidget);
          expect(find.text('TITLE'), findsNothing);
        });
      }
    });
  });
}

/// Text in the page's top bar on either design language.
Finder _inBar(String text) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is AppBar ||
        widget is CupertinoNavigationBar ||
        widget is CupertinoSliverNavigationBar,
  ),
  matching: find.text(text),
);

Finder _inside(Type container, String text) =>
    find.descendant(of: find.byType(container), matching: find.text(text));

Color? _textColor(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style.color;
