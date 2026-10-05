import 'dart:async';
import 'dart:developer';

import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.widget.dart';

import '../../extensions/modal.extension.dart';
import '../../widgets/account/account.cubit.dart';
import '../../widgets/account/account_avatar.widget.dart';
import '../../widgets/account/account_modal.widget.dart';
import '../../widgets/app_modal.widget.dart';
import '../../widgets/webview_modal.widget.dart';
import 'bloc/home.bloc.dart';

part 'widgets/home_primary_actions.widget.dart';
part 'widgets/home_showcase.widget.dart';

class Home extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.I<HomeBloc>()..add(const HomeStarted()),
        ),
        BlocProvider(create: (_) => GetIt.I<AccountCubit>()),
      ],
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.lastAction != current.lastAction && current.hasLastAction,
        listener: (context, state) {
          final action = state.lastAction;

          if (action != null) {
            log('Home action pressed: $action');
          }
        },
        child: const _HomeView(),
      ),
    );
  }
}

/// The Home tab: the page chrome with the account action, over the showcase.
class _HomeView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.homeTab,
      titleBehavior: PageTitleBehavior.large,
      trailingAction: ToolBarAction.avatar(
        avatar: BlocSelector<AccountCubit, AccountState, Profile>(
          selector: (state) => state.profile,
          builder: (context, profile) =>
              AccountAvatar(profile: profile, size: 32),
        ),
        tooltip: l10n.accountAvatarLabel,
        onPressed: () => unawaited(showAccountModal(context)),
      ),
      body: const _HomeShowcase(),
    );
  }
}
