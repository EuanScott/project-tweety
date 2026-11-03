import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation.extension.dart';
import 'package:project_tweety/presentation/widgets/scene_layout/scene_frame.model.dart';
import 'package:project_tweety/presentation/widgets/scene_layout/scene_layout.widget.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

import 'cubit/compass_heading.cubit.dart';
import 'map_scene_palette.model.dart';

part 'widgets/route_error_message.widget.dart';
part 'widgets/route_error_scene.widget.dart';

/// The page the router shows when it cannot resolve a location, most often a
/// deep link to a page that does not exist.
///
/// It sits over Home and covers the tab bar, so "Go home", swipe-back and the
/// back button all go back to Home. It is laid out as Sign-in is: a map scene
/// with a compass in the sky panel, and the message beside or below it.
class RouteErrorPage extends StatelessWidget {
  const new({super.key});

  @visibleForTesting
  static const ValueKey<String> compactLayoutKey = ValueKey(
    'route-error-compact',
  );

  @visibleForTesting
  static const ValueKey<String> splitLayoutKey = ValueKey('route-error-split');

  @visibleForTesting
  static const ValueKey<String> sceneKey = ValueKey('route-error-scene');

  /// The compass needle, turned to the heading.
  @visibleForTesting
  static const ValueKey<String> needleKey = ValueKey('route-error-needle');

  /// One of `rings`, `farMap`, `nearMap`, `smallMap`, `pin` or `compass`.
  @visibleForTesting
  static ValueKey<String> layerKey(String layer) =>
      ValueKey('route-error-layer-$layer');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<SceneTiltCubit>()),
        BlocProvider(create: (_) => GetIt.I<CompassHeadingCubit>()),
      ],
      child: const PaneLayoutScope(child: _RouteErrorView()),
    );
  }
}

class _RouteErrorView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (PaneLayoutScope.of(context)) {
        PaneLayoutMode.compact => SceneCompactLayout(
          key: RouteErrorPage.compactLayoutKey,
          sceneKey: RouteErrorPage.sceneKey,
          scene: (context, frame) => _RouteErrorScene(frame: frame),
          body: const _RouteErrorMessage(isSplit: false),
          footer: const _RouteErrorGoHome(),
        ),
        PaneLayoutMode.split => SceneSplitLayout(
          key: RouteErrorPage.splitLayoutKey,
          scene: (context, frame) => KeyedSubtree(
            key: RouteErrorPage.sceneKey,
            child: _RouteErrorScene(frame: frame),
          ),
          content: const Column(
            crossAxisAlignment: .start,
            spacing: 32,
            children: [_RouteErrorMessage(isSplit: true), _RouteErrorGoHome()],
          ),
        ),
      },
    );
  }
}
