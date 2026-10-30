import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('names the pane with its title and offers no back button on '
        '${platform.name}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystemTheme.light().copyWith(platform: platform),
          home: const Scaffold(body: AppPaneHeader(title: 'Edit entry')),
        ),
      );

      expect(find.text('Edit entry'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
    });
  }

  testWidgets('centres the title on iOS and starts it on Android', (
    tester,
  ) async {
    Future<double> titleLeft(TargetPlatform platform) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystemTheme.light().copyWith(platform: platform),
          home: const Scaffold(body: AppPaneHeader(title: 'Edit entry')),
        ),
      );
      await tester.pumpAndSettle();
      return tester.getTopLeft(find.text('Edit entry')).dx;
    }

    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final iosLeft = await titleLeft(TargetPlatform.iOS);
    final iosWidth = tester.getSize(find.text('Edit entry')).width;
    final androidLeft = await titleLeft(TargetPlatform.android);

    expect(iosLeft + iosWidth / 2, moreOrLessEquals(screenWidth / 2));
    expect(androidLeft, lessThan(32));
  });
}
