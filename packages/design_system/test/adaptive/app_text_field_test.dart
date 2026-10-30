import 'package:design_system/design_system.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a material field with label and error text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            label: 'Title',
            errorText: 'Title is required',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Title is required'), findsOneWidget);
  });

  testWidgets('renders a Cupertino field with label and error text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            label: 'Description',
            errorText: 'Description is required',
            maxLines: 4,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });

  testWidgets('draws the Cupertino error in the theme error colour, which '
      'keeps 4.5:1 on the white row where system red does not', (tester) async {
    const themeError = Color(0xFFD32F2F);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          colorScheme: const ColorScheme.light(error: themeError),
        ),
        home: Scaffold(
          body: AppTextField(
            controller: TextEditingController(),
            label: 'Title',
            errorText: 'Title is required',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Title is required')).style?.color,
      themeError,
    );
  });

  testWidgets('renders a Cupertino field as a grouped row under an upper-case '
      'section label', (tester) async {
    await tester.pumpWidget(
      _onPlatform(
        TargetPlatform.iOS,
        AppTextField(
          controller: TextEditingController(),
          label: 'Description',
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.text('DESCRIPTION'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(CupertinoTextField),
        matching: find.byType(CupertinoListSection),
      ),
      findsOneWidget,
    );
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('asks the ${platform.name} keyboard to capitalise sentences by '
        'default', (tester) async {
      await tester.pumpWidget(
        _onPlatform(
          platform,
          AppTextField(
            controller: TextEditingController(),
            label: 'Title',
            onChanged: (_) {},
          ),
        ),
      );

      expect(_textCapitalization(tester), TextCapitalization.sentences);
    });

    testWidgets('passes a chosen capitalisation to the ${platform.name} '
        'keyboard', (tester) async {
      await tester.pumpWidget(
        _onPlatform(
          platform,
          AppTextField(
            controller: TextEditingController(),
            label: 'Email',
            textCapitalization: TextCapitalization.none,
            onChanged: (_) {},
          ),
        ),
      );

      expect(_textCapitalization(tester), TextCapitalization.none);
    });
  }
}

Widget _onPlatform(TargetPlatform platform, Widget field) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: Scaffold(body: field),
  );
}

TextCapitalization _textCapitalization(WidgetTester tester) {
  return tester
      .widget<EditableText>(find.byType(EditableText))
      .textCapitalization;
}
