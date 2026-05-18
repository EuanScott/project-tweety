import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

enum _TestTab { home, settings }

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
  });
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
  return GoRoute(path: path, builder: (_, _) => const SizedBox.shrink());
}

Widget _errorBuilder(BuildContext context, Exception? error) {
  return const SizedBox.shrink();
}
