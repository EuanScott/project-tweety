// ignore_for_file: depend_on_referenced_packages

import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDesignPlatform', () {
    testWidgets('resolves Android to Material', (tester) async {
      late AppDesignPlatform platform;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              platform = AppDesignPlatform.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(platform, AppDesignPlatform.material);
      expect(platform.isCupertino, isFalse);
    });

    testWidgets('resolves iOS to Cupertino', (tester) async {
      late AppDesignPlatform platform;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              platform = AppDesignPlatform.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(platform, AppDesignPlatform.cupertino);
      expect(platform.isCupertino, isTrue);
    });
  });

  group('AppLoadingIndicator', () {
    testWidgets('renders a Material progress indicator on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const AppLoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('renders a Cupertino activity indicator on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const AppLoadingIndicator(),
        ),
      );

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('AppRefreshIndicator', () {
    testWidgets('renders an adaptive refresh indicator wrapper', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppRefreshIndicator(
            onRefresh: () async {},
            child: ListView(children: const [Text('Content')]),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('AppButton', () {
    testWidgets('renders a Material button on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const AppButton.primary(
            onPressed: _noop,
            child: Text('Continue'),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('renders a Cupertino button on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1BA6A6),
              onPrimary: Colors.white,
            ),
            platform: TargetPlatform.iOS,
          ),
          home: const AppButton.primary(
            onPressed: _noop,
            child: Text('Continue'),
          ),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(_textColor(tester, 'Continue'), Colors.white);
    });

    testWidgets('renders a tinted secondary Cupertino button on iOS', (
      tester,
    ) async {
      const primary = Color(0xFF1BA6A6);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(primary: primary),
            platform: TargetPlatform.iOS,
          ),
          home: const AppButton.secondary(
            onPressed: _noop,
            child: Text('Cancel'),
          ),
        ),
      );

      final expectedTint = primary.withAlpha(31);
      final hasExpectedTint = tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('Cancel'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((decoratedBox) => decoratedBox.decoration)
          .whereType<BoxDecoration>()
          .any((decoration) => decoration.color == expectedTint);

      expect(hasExpectedTint, isTrue);
      expect(_textColor(tester, 'Cancel'), primary);
    });

    testWidgets('renders a destructive Material button on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const AppButton.destructive(
            onPressed: _noop,
            child: Text('Delete'),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });

    testWidgets('renders a destructive Cupertino button on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const AppButton.destructive(
            onPressed: _noop,
            child: Text('Delete'),
          ),
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('showAppConfirmationDialog', () {
    testWidgets('renders a Material confirmation with caller-owned copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppConfirmationDialog(
                context: context,
                title: 'Delete card?',
                content: 'This cannot be undone.',
                cancelLabel: 'Keep',
                confirmLabel: 'Delete',
                isDestructive: true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete card?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });

    testWidgets('renders a Cupertino confirmation with caller-owned copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showAppConfirmationDialog(
                context: context,
                title: 'Delete card?',
                content: 'This cannot be undone.',
                cancelLabel: 'Keep',
                confirmLabel: 'Delete',
                isDestructive: true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Delete card?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });
  });

  group('AppListTile', () {
    testWidgets('renders a Material list tile on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: const Scaffold(
            body: AppListTile(title: Text('Settings'), onTap: _noop),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNothing);
    });

    testWidgets('renders a Cupertino list tile on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const AppListTile(title: Text('Settings'), onTap: _noop),
        ),
      );

      expect(find.byType(CupertinoListTile), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });
  });

  group('AppPickerField', () {
    testWidgets('renders a Material dropdown on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Scaffold(
            body: AppPickerField<String>(
              label: 'Theme',
              value: 'system',
              options: const [
                AppPickerOption(value: 'system', label: 'System'),
                AppPickerOption(value: 'dark', label: 'Dark'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNothing);
    });

    testWidgets('renders a Cupertino picker row on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: AppPickerField<String>(
              label: 'Theme',
              value: 'system',
              options: const [
                AppPickerOption(value: 'system', label: 'System'),
                AppPickerOption(value: 'dark', label: 'Dark'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoListTile), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('System'), findsOneWidget);
    });
  });
}

Color? _textColor(WidgetTester tester, String text) {
  return DefaultTextStyle.of(tester.element(find.text(text))).style.color;
}

void _noop() {}
