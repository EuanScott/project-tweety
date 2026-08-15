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
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
  });
}
