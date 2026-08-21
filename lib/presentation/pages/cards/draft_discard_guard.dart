import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';

import 'bloc/cards.bloc.dart';

class const CardsDraftDiscardGuard({required final Widget child, super.key})
    extends StatefulWidget {
  static Future<void> discardThen(
    BuildContext context,
    VoidCallback onDiscard,
  ) {
    return context
        .findAncestorStateOfType<_CardsDraftDiscardGuardState>()!
        .discardThen(onDiscard);
  }

  @override
  State<CardsDraftDiscardGuard> createState() => _CardsDraftDiscardGuardState();
}

class _CardsDraftDiscardGuardState extends State<CardsDraftDiscardGuard> {
  late final TabBranchResetGuard<AppTab> _branchResetGuard;
  TabReselectController<AppTab>? _controller;
  var _isConfirmationShowing = false;

  @override
  void initState() {
    super.initState();
    _branchResetGuard = TabBranchResetGuard<AppTab>(
      tab: AppTab.cards,
      onResetRequested: _requestBranchReset,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = TabReselectScope.maybeOf<AppTab>(context);
    if (controller == _controller) {
      return;
    }
    _controller?.unregisterBranchResetGuard(_branchResetGuard);
    _controller = controller;
    _controller?.registerBranchResetGuard(_branchResetGuard);
  }

  @override
  void dispose() {
    _controller?.unregisterBranchResetGuard(_branchResetGuard);
    super.dispose();
  }

  Future<void> discardThen(VoidCallback onDiscard) async {
    if (!await _canDiscard()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final state = context.read<CardsBloc>().state;
    if (state.isCreating || state.isEditing) {
      context.read<CardsBloc>().add(const CardsDraftDiscarded());
    }
    onDiscard();
  }

  Future<bool> _requestBranchReset() async {
    final canDiscard = await _canDiscard();
    if (canDiscard && mounted) {
      final state = context.read<CardsBloc>().state;
      if (state.isCreating || state.isEditing) {
        context.read<CardsBloc>().add(const CardsDraftDiscarded());
      }
    }
    return canDiscard;
  }

  Future<bool> _canDiscard() async {
    if (!context.read<CardsBloc>().state.isDraftDirty) {
      return true;
    }
    if (_isConfirmationShowing) {
      return false;
    }
    setState(() => _isConfirmationShowing = true);
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.cardDiscardConfirmationTitle,
      content: l10n.cardDiscardConfirmationDescription,
      cancelLabel: l10n.cardDiscardCancelAction,
      confirmLabel: l10n.cardDiscardAction,
      isDestructive: true,
    );
    if (mounted) {
      setState(() => _isConfirmationShowing = false);
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
