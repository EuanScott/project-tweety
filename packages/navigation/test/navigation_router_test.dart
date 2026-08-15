import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { home, settings }

const _compactAppBarBackground = Color(0xFFAA0000);
const _compactAppBarForeground = Color(0xFFFFFFFF);
const _railSurface = Color(0xFFE5F5F4);
const _railForeground = Color(0xFF0F5D5D);
const _drawerSurface = Color(0xFFEAF1FF);
const _drawerForeground = Color(0xFF1F3C88);
const _homeThemeProbeKey = ValueKey('home-theme-probe');
const _sideNavigationToggleTooltip = 'Toggle side navigation';

void main() {
  group('createNavigationRouter', () {
    test('throws when tabs are empty', () {
      expect(
        () => createNavigationRouter<_TestTab>(
          initialLocation: '/',
          rootPath: '/',
          rootRedirectPath: '/home',
          tabs: const [],
          branches: const [],
          errorBuilder: _errorBuilder,
        ),
        throwsArgumentError,
      );
    });

    test('throws when tab and branch counts differ', () {
      expect(
        () => createNavigationRouter<_TestTab>(
          initialLocation: '/',
          rootPath: '/',
          rootRedirectPath: '/home',
          tabs: [_tabConfig(_TestTab.home, '/home', 'home')],
          branches: const [],
          errorBuilder: _errorBuilder,
        ),
        throwsArgumentError,
      );
    });

    test('throws when a tab is missing a matching branch', () {
      expect(
        () => createNavigationRouter<_TestTab>(
          initialLocation: '/',
          rootPath: '/',
          rootRedirectPath: '/home',
          tabs: [_tabConfig(_TestTab.home, '/home', 'home')],
          branches: [
            NavigationBranch<_TestTab>(
              tab: _TestTab.settings,
              routes: [_route('/settings')],
            ),
          ],
          errorBuilder: _errorBuilder,
        ),
        throwsArgumentError,
      );
    });

    testWidgets('renders a bottom navigation bar at compact width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(500, 800));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders a Cupertino tab bar at compact iOS width', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(500, 800),
      );

      expect(find.byType(CupertinoTabBar), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets('renders an unextended navigation rail at medium width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(700, 800));

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(rail.extended, isFalse);
    });

    testWidgets('renders Cupertino side navigation at medium iOS width', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(700, 800),
      );

      expect(find.byType(CupertinoListSection), findsNothing);
      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(CupertinoTabBar), findsNothing);
    });

    testWidgets('can collapse and expand Cupertino side navigation', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(700, 800),
      );

      expect(_sideNavigationWidth(tester), 304);
      expect(find.text('home'), findsOneWidget);

      await tester.tap(find.byTooltip(_sideNavigationToggleTooltip));
      await tester.pumpAndSettle();

      expect(_sideNavigationWidth(tester), 72);
      expect(find.text('home'), findsNothing);

      await tester.tap(find.byTooltip(_sideNavigationToggleTooltip));
      await tester.pumpAndSettle();

      expect(_sideNavigationWidth(tester), 304);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('keeps the navigation rail compact at expanded width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(900, 800));

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(rail.extended, isFalse);
      expect(rail.labelType, NavigationRailLabelType.all);
    });

    testWidgets('renders a navigation drawer at tablet width', (tester) async {
      await _pumpRouter(tester, surfaceSize: const Size(1200, 800));

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsOneWidget);
    });

    testWidgets('can collapse and expand Material side navigation', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(1200, 800));

      expect(_sideNavigationWidth(tester), 304);
      expect(find.byType(NavigationDrawer), findsOneWidget);

      await tester.tap(find.byTooltip(_sideNavigationToggleTooltip));
      await tester.pumpAndSettle();

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));

      expect(_sideNavigationWidth(tester), 72);
      expect(rail.labelType, NavigationRailLabelType.none);
      expect(find.byType(NavigationDrawer), findsNothing);

      await tester.tap(find.byTooltip(_sideNavigationToggleTooltip));
      await tester.pumpAndSettle();

      expect(_sideNavigationWidth(tester), 304);
      expect(find.byType(NavigationDrawer), findsOneWidget);
    });

    testWidgets('renders Cupertino side navigation at tablet iOS width', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1200, 800),
      );

      expect(find.byType(CupertinoListSection), findsNothing);
      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(CupertinoTabBar), findsNothing);
    });

    testWidgets('keeps the app bar theme unchanged at compact width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(500, 800));

      final appBarTheme = Theme.of(
        tester.element(find.byKey(_homeThemeProbeKey)),
      ).appBarTheme;

      expect(appBarTheme.backgroundColor, _compactAppBarBackground);
      expect(appBarTheme.foregroundColor, _compactAppBarForeground);
    });

    testWidgets('uses rail colors for app bars at medium width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(700, 800));

      final appBarTheme = Theme.of(
        tester.element(find.byKey(_homeThemeProbeKey)),
      ).appBarTheme;

      expect(appBarTheme.backgroundColor, _railSurface);
      expect(appBarTheme.foregroundColor, _railForeground);
      expect(appBarTheme.titleTextStyle?.color, _railForeground);
    });

    testWidgets('uses drawer colors for app bars at tablet width', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(1200, 800));

      final appBarTheme = Theme.of(
        tester.element(find.byKey(_homeThemeProbeKey)),
      ).appBarTheme;

      expect(appBarTheme.backgroundColor, _drawerSurface);
      expect(appBarTheme.foregroundColor, _drawerForeground);
      expect(appBarTheme.titleTextStyle?.color, _drawerForeground);
    });
  });
}

Future<void> _pumpRouter(
  WidgetTester tester, {
  required Size surfaceSize,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  await tester.binding.setSurfaceSize(surfaceSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = createNavigationRouter<_TestTab>(
    initialLocation: '/home',
    rootPath: '/',
    rootRedirectPath: '/home',
    tabs: [
      _tabConfig(_TestTab.home, '/home', 'home'),
      _tabConfig(_TestTab.settings, '/settings', 'settings'),
    ],
    branches: [
      NavigationBranch<_TestTab>(tab: _TestTab.home, routes: [_route('/home')]),
      NavigationBranch<_TestTab>(
        tab: _TestTab.settings,
        routes: [_route('/settings')],
      ),
    ],
    errorBuilder: _errorBuilder,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(theme: _themeData(platform), routerConfig: router),
  );
  await tester.pumpAndSettle();
}

ThemeData _themeData(TargetPlatform platform) {
  return ThemeData(
    platform: platform,
    appBarTheme: const AppBarTheme(
      backgroundColor: _compactAppBarBackground,
      foregroundColor: _compactAppBarForeground,
      titleTextStyle: TextStyle(color: _compactAppBarForeground),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _railSurface,
      unselectedIconTheme: IconThemeData(color: _railForeground),
      unselectedLabelTextStyle: TextStyle(color: _railForeground),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: _drawerSurface,
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: _drawerForeground),
      ),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _drawerForeground),
      ),
    ),
  );
}

NavigationTabConfig<_TestTab> _tabConfig(
  _TestTab tab,
  String rootPath,
  String routeName,
) {
  return NavigationTabConfig<_TestTab>(
    tab: tab,
    rootPath: rootPath,
    routeName: routeName,
    icon: const IconData(0),
    labelBuilder: (_) => routeName,
  );
}

GoRoute _route(String path) {
  return GoRoute(
    path: path,
    builder: (_, _) => Scaffold(
      appBar: AppBar(title: Text(path)),
      body: SizedBox(key: path == '/home' ? _homeThemeProbeKey : null),
    ),
  );
}

Widget _errorBuilder(BuildContext context, Exception? error) {
  return const SizedBox.shrink();
}

double _sideNavigationWidth(WidgetTester tester) {
  return tester
      .getSize(
        find
            .ancestor(
              of: find.byTooltip(_sideNavigationToggleTooltip),
              matching: find.byType(SizedBox),
            )
            .first,
      )
      .width;
}
