import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/di/dependency_injection.dart';

import 'package:project_tweety/main.dart';

void main() {
  setUpAll(() async {
    await GetIt.I.reset();
    await configureCoreDependencies();
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  testWidgets('renders app navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('switches to cards tab', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();

    expect(find.text('Card Title 1'), findsOneWidget);
  });
}
