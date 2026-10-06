import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { home, settings }

const _appBarBackground = Color(0xFFAA0000);
const _appBarForeground = Color(0xFFFFFFFF);
const _railSurface = Color(0xFFE5F5F4);
const _railForeground = Color(0xFF0F5D5D);
const _drawerSurface = Color(0xFFEAF1FF);
const _drawerForeground = Color(0xFF1F3C88);
const _homeThemeProbeKey = ValueKey('home-theme-probe');
const _errorProbeKey = ValueKey<String>('error-probe');
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

    final builderRoute = GoRoute(
      path: 'builder',
      builder: (_, _) => const SizedBox.shrink(),
    );
    for (final (label, branchRoutes, extraRoutes) in [
      (
        'a branch child route',
        [
          _route('/settings', routes: [builderRoute]),
        ],
        <RouteBase>[],
      ),
      (
        'a route inside a ShellRoute',
        [
          ShellRoute(
            builder: (_, _, child) => child,
            routes: [
              _route('/settings', routes: [builderRoute]),
            ],
          ),
        ],
        <RouteBase>[],
      ),
      (
        'a route outside the tab shell',
        [_route('/settings')],
        <RouteBase>[
          GoRoute(path: '/gate', builder: (_, _) => const SizedBox.shrink()),
        ],
      ),
    ]) {
      test('throws when $label uses builder instead of pageBuilder', () {
        expect(
          () => createNavigationRouter<_TestTab>(
            initialLocation: '/',
            rootPath: '/',
            rootRedirectPath: '/settings',
            tabs: [_tabConfig(_TestTab.settings, '/settings', 'settings')],
            branches: [
              NavigationBranch<_TestTab>(
                tab: _TestTab.settings,
                routes: branchRoutes,
              ),
            ],
            routes: extraRoutes,
            errorBuilder: _errorBuilder,
          ),
          throwsArgumentError,
        );
      });
    }

    testWidgets(
      'renders extra routes outside the tab shell and re-runs the redirect '
      'when the refresh listenable notifies',
      (tester) async {
        final isGated = ValueNotifier(true);
        addTearDown(isGated.dispose);

        await _pumpRouter(
          tester,
          surfaceSize: const Size(500, 800),
          routes: [_route('/gate')],
          redirect: (context, state) {
            final isOnGate = state.matchedLocation == '/gate';
            if (isGated.value) {
              return isOnGate ? null : '/gate';
            }

            return isOnGate ? '/settings' : null;
          },
          refreshListenable: isGated,
        );

        expect(find.text('/gate'), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);

        isGated.value = false;
        await tester.pumpAndSettle();

        expect(find.text('/settings'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
      },
    );

    for (final (platform, routeType) in [
      (TargetPlatform.iOS, CupertinoPageRoute<void>),
      (TargetPlatform.android, MaterialPageRoute<void>),
    ]) {
      testWidgets('pushes a $platform page that slides in and swipes back', (
        tester,
      ) async {
        await _pumpRouter(
          tester,
          surfaceSize: const Size(500, 800),
          platform: platform,
          initialLocation: '/settings',
          settingsChildren: [_route('detail')],
        );

        unawaited(
          GoRouter.of(tester.element(find.text('/settings'))).push(
            '/settings/detail',
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final route = ModalRoute.of(tester.element(find.text('detail')))!;
        expect(route.animation!.isAnimating, isTrue);
        expect(
          route,
          platform == TargetPlatform.iOS
              ? isA<CupertinoRouteTransitionMixin<void>>()
              : isA<MaterialRouteTransitionMixin<void>>(),
          reason: '$routeType',
        );

        await tester.pumpAndSettle();
        if (platform != TargetPlatform.iOS) {
          return;
        }

        await tester.dragFrom(const Offset(5, 400), const Offset(400, 0));
        await tester.pumpAndSettle();

        expect(find.text('detail'), findsNothing);
        expect(find.text('/settings'), findsOneWidget);
      });
    }

    testWidgets('shows an unknown location on the native iOS page', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        surfaceSize: const Size(500, 800),
        platform: TargetPlatform.iOS,
        initialLocation: '/nowhere',
      );

      expect(
        ModalRoute.of(tester.element(find.byKey(_errorProbeKey))),
        isA<CupertinoRouteTransitionMixin<void>>(),
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

    testWidgets('keeps the Cupertino tab bar on an iPhone in landscape', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(844, 390),
      );

      expect(find.byType(CupertinoTabBar), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNothing);
      expect(find.byTooltip(_sideNavigationToggleTooltip), findsNothing);
    });

    testWidgets('renders Cupertino side navigation on an iPad in landscape', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(1194, 834),
      );

      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      expect(find.byType(CupertinoTabBar), findsNothing);
    });

    testWidgets('renders a navigation rail on an Android phone in landscape', (
      tester,
    ) async {
      await _pumpRouter(tester, surfaceSize: const Size(844, 390));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
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

    testWidgets('shows the selected sidebar row without a checkmark', (
      tester,
    ) async {
      await _pumpRouter(
        tester,
        platform: TargetPlatform.iOS,
        surfaceSize: const Size(700, 800),
      );

      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      expect(find.byIcon(CupertinoIcons.check_mark), findsNothing);
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

    for (final width in [500.0, 700.0, 1200.0]) {
      testWidgets('keeps the app bar theme unchanged at width $width', (
        tester,
      ) async {
        await _pumpRouter(tester, surfaceSize: Size(width, 800));

        final appBarTheme = Theme.of(
          tester.element(find.byKey(_homeThemeProbeKey)),
        ).appBarTheme;

        expect(appBarTheme.backgroundColor, _appBarBackground);
        expect(appBarTheme.foregroundColor, _appBarForeground);
        expect(appBarTheme.titleTextStyle?.color, _appBarForeground);
      });
    }
  });
}

Future<void> _pumpRouter(
  WidgetTester tester, {
  required Size surfaceSize,
  TargetPlatform platform = TargetPlatform.android,
  String initialLocation = '/home',
  List<RouteBase> settingsChildren = const [],
  List<RouteBase> routes = const [],
  GoRouterRedirect? redirect,
  Listenable? refreshListenable,
}) async {
  tester.view
    ..physicalSize = surfaceSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = createNavigationRouter<_TestTab>(
    initialLocation: initialLocation,
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
        routes: [_route('/settings', routes: settingsChildren)],
      ),
    ],
    errorBuilder: _errorBuilder,
    routes: routes,
    redirect: redirect,
    refreshListenable: refreshListenable,
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
      backgroundColor: _appBarBackground,
      foregroundColor: _appBarForeground,
      titleTextStyle: TextStyle(color: _appBarForeground),
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

GoRoute _route(String path, {List<RouteBase> routes = const []}) {
  return GoRoute(
    path: path,
    routes: routes,
    pageBuilder: (context, state) => platformPage(
      context,
      state,
      Scaffold(
        appBar: AppBar(title: Text(path)),
        body: SizedBox(key: path == '/home' ? _homeThemeProbeKey : null),
      ),
    ),
  );
}

Widget _errorBuilder(BuildContext context, Exception? error) {
  return const SizedBox.shrink(key: _errorProbeKey);
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
