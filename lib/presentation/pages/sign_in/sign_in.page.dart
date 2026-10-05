import 'dart:async';
import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/sign_in_result.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

import 'cubit/sign_in.cubit.dart';

part 'widgets/sign_in_block.widget.dart';
part 'widgets/sign_in_compact.widget.dart';
part 'widgets/sign_in_error.widget.dart';
part 'widgets/sign_in_scene.widget.dart';
part 'widgets/sign_in_split.widget.dart';

/// The sign-in page. The launch gate shows it to anyone who is signed out.
///
/// It sits outside the tab shell and never navigates: a successful sign-in
/// changes the Session, and the gate moves the person into the app.
class SignInPage extends StatelessWidget {
  const new({super.key});

  @visibleForTesting
  static const ValueKey<String> compactLayoutKey = ValueKey('sign-in-compact');

  @visibleForTesting
  static const ValueKey<String> splitLayoutKey = ValueKey('sign-in-split');

  @visibleForTesting
  static const ValueKey<String> scenePaneKey = ValueKey('sign-in-scene');

  @visibleForTesting
  static const ValueKey<String> formPaneKey = ValueKey('sign-in-form');

  @visibleForTesting
  static const ValueKey<String> errorKey = ValueKey('sign-in-error');

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<SignInCubit>()),
        BlocProvider(create: (_) => GetIt.I<SceneTiltCubit>()),
      ],
      child: const PaneLayoutScope(child: _SignInView()),
    );
  }
}

class _SignInView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (PaneLayoutScope.of(context)) {
        PaneLayoutMode.compact => const _SignInCompact(
          key: SignInPage.compactLayoutKey,
        ),
        PaneLayoutMode.split => const _SignInSplit(
          key: SignInPage.splitLayoutKey,
        ),
      },
    );
  }
}
