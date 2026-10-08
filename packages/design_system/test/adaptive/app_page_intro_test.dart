import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _description =
    'Change the appearance, theme colour, language and text of the app.';

Widget _host(TargetPlatform platform, {Brightness brightness = .light}) {
  return MaterialApp(
    theme: ThemeData(platform: platform, brightness: brightness),
    home: const Scaffold(
      body: SizedBox(
        width: 320,
        child: AppPageIntro(description: _description),
      ),
    ),
  );
}

Finder _decoratedAncestors() {
  return find.ancestor(
    of: find.text(_description),
    matching: find.byWidgetPredicate(
      (widget) =>
          (widget is DecoratedBox && widget.decoration is BoxDecoration) ||
          (widget is Container && widget.decoration != null),
    ),
  );
}

void main() {
  group('AppPageIntro', () {
    for (final (brightness, raised) in [
      (Brightness.light, (ColorScheme scheme) => scheme.surfaceContainer),
      (Brightness.dark, (ColorScheme scheme) => scheme.surface),
    ]) {
      testWidgets('puts the text in a rounded raised card on iOS in '
          '${brightness.name} mode', (tester) async {
        await tester.pumpWidget(
          _host(TargetPlatform.iOS, brightness: brightness),
        );

        final context = tester.element(find.text(_description));
        final card = tester.widget<DecoratedBox>(_decoratedAncestors().first);
        final decoration = card.decoration as BoxDecoration;

        expect(decoration.color, raised(Theme.of(context).colorScheme));
        expect(decoration.borderRadius, BorderRadius.circular(10));
      });
    }

    testWidgets('sizes the iOS card and text like an inset grouped cell', (
      tester,
    ) async {
      await tester.pumpWidget(_host(TargetPlatform.iOS));

      final context = tester.element(find.text(_description));
      final text = tester.widget<Text>(find.text(_description));
      final card = tester.getRect(_decoratedAncestors().first);
      final textRect = tester.getRect(find.text(_description));
      final intro = tester.getRect(find.byType(AppPageIntro));

      expect(text.style?.fontSize, 15);
      expect(text.style?.height, 20 / 15);
      expect(
        text.style?.color,
        CupertinoColors.secondaryLabel.resolveFrom(context),
      );
      expect(card.left - intro.left, 16);
      expect(intro.right - card.right, 16);
      expect(card.top - intro.top, 20);
      expect(intro.bottom - card.bottom, 8);
      expect(textRect.left - card.left, 16);
      expect(textRect.top - card.top, 12);
      expect(card.bottom - textRect.bottom, 12);
    });

    testWidgets('shows plain text with no card on Android', (tester) async {
      await tester.pumpWidget(_host(TargetPlatform.android));

      final context = tester.element(find.text(_description));
      final theme = Theme.of(context);
      final text = tester.widget<Text>(find.text(_description));
      final textRect = tester.getRect(find.text(_description));
      final intro = tester.getRect(find.byType(AppPageIntro));

      expect(_decoratedAncestors(), findsNothing);
      expect(find.byType(Card), findsNothing);
      expect(text.style?.color, theme.colorScheme.onSurfaceVariant);
      expect(text.style?.fontSize, theme.textTheme.bodyMedium?.fontSize);
      expect(text.style?.height, theme.textTheme.bodyMedium?.height);
      expect(textRect.left - intro.left, 16);
      expect(intro.right - textRect.right, 16);
      expect(textRect.top - intro.top, 16);
      expect(intro.bottom, textRect.bottom);
    });

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('wraps a long description on ${platform.name}', (
        tester,
      ) async {
        await tester.pumpWidget(_host(platform));

        expect(
          tester.getSize(find.text(_description)).height,
          greaterThan(20 * 1.5),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
