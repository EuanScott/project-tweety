import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _longFooter =
    'Change font size and bold text in your device settings, which apply to '
    'every app on this device and not only to this one.';

Widget _host(TargetPlatform platform, Widget child) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Scaffold(body: SizedBox(width: 320, child: child)),
  );
}

AppListSection _section() {
  return const AppListSection(
    header: 'Appearance',
    footer: _longFooter,
    children: [
      AppListTile(title: Text('First row')),
      AppListTile(title: Text('Second row')),
    ],
  );
}

void main() {
  group('AppListSection', () {
    testWidgets('renders an inset grouped section on iOS', (tester) async {
      await tester.pumpWidget(_host(TargetPlatform.iOS, _section()));

      expect(find.byType(CupertinoListSection), findsOneWidget);
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(find.text('First row'), findsOneWidget);
      expect(find.text('Second row'), findsOneWidget);
      expect(find.text(_longFooter), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('renders a subheader, rows and a divider on Android', (
      tester,
    ) async {
      await tester.pumpWidget(_host(TargetPlatform.android, _section()));

      expect(find.byType(CupertinoListSection), findsNothing);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('First row'), findsOneWidget);
      expect(find.text(_longFooter), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      final header = tester.widget<Text>(find.text('Appearance'));
      final context = tester.element(find.text('Appearance'));
      expect(header.style?.color, Theme.of(context).colorScheme.primary);
    });

    testWidgets('gives Material rows 16 px of side padding', (tester) async {
      await tester.pumpWidget(_host(TargetPlatform.android, _section()));

      final rowLeft = tester.getTopLeft(find.text('First row')).dx;
      final sectionLeft = tester.getTopLeft(find.byType(AppListSection)).dx;

      expect(rowLeft - sectionLeft, 16);
    });

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('wraps the footer on ${platform.name}', (tester) async {
        await tester.pumpWidget(_host(platform, _section()));

        final footerHeight = tester.getSize(find.text(_longFooter)).height;
        final rowTextHeight = tester.getSize(find.text('First row')).height;

        expect(footerHeight, greaterThan(rowTextHeight * 1.5));
        expect(tester.takeException(), isNull);
      });
    }

    for (final (platform, fontSize) in [
      (TargetPlatform.iOS, 17.0),
      (TargetPlatform.android, 16.0),
    ]) {
      testWidgets('titles a content row at $fontSize px on ${platform.name}', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(
            platform,
            const AppListSection(
              children: [
                AppListSectionContent(
                  title: 'Theme colour',
                  child: SizedBox(key: Key('content'), height: 40),
                ),
              ],
            ),
          ),
        );

        final title = tester.widget<Text>(find.text('Theme colour'));

        expect(title.style?.fontSize, fontSize);
        expect(
          tester.getTopLeft(find.byKey(const Key('content'))).dy,
          greaterThan(tester.getBottomLeft(find.text('Theme colour')).dy),
        );
      });
    }

    testWidgets('leaves out the header and footer when not given', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          TargetPlatform.android,
          const AppListSection(children: [AppListTile(title: Text('Only'))]),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
