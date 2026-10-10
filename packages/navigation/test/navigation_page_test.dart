import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:navigation/navigation.dart';

void main() {
  group('platformPage', () {
    testWidgets('locations that share a key update one page in place', (
      tester,
    ) async {
      final router = _router(sharedKey: const ValueKey('shared'));
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/a');
      await tester.pumpAndSettle();
      final routeAtA = ModalRoute.of(tester.element(find.text('/a')));

      router.go('/b');
      await tester.pump();

      expect(ModalRoute.of(tester.element(find.text('/b'))), same(routeAtA));
      expect(find.text('/a'), findsNothing);
    });

    testWidgets('locations without a shared key each get their own page', (
      tester,
    ) async {
      final router = _router();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/a');
      await tester.pumpAndSettle();
      final routeAtA = ModalRoute.of(tester.element(find.text('/a')));

      router.go('/b');
      await tester.pumpAndSettle();

      expect(
        ModalRoute.of(tester.element(find.text('/b'))),
        isNot(same(routeAtA)),
      );
    });
  });
}

GoRouter _router({LocalKey? sharedKey}) {
  GoRoute child(String path) => GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        platformPage(context, state, Text('/$path'), key: sharedKey),
  );

  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            platformPage(context, state, const Text('/')),
        routes: [child('a'), child('b')],
      ),
    ],
  );
}
