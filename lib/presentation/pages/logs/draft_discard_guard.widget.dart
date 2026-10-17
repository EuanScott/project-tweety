import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.model.dart';

import 'bloc/logs.bloc.dart';

class const LogsDraftDiscardGuard({required final Widget child, super.key})
    extends StatefulWidget {
  static Future<void> discardThen(
    BuildContext context,
    VoidCallback onDiscard,
  ) {
    return context
        .findAncestorStateOfType<_LogsDraftDiscardGuardState>()!
        .discardThen(onDiscard);
  }

  @override
  State<LogsDraftDiscardGuard> createState() => _LogsDraftDiscardGuardState();
}

class _LogsDraftDiscardGuardState extends State<LogsDraftDiscardGuard> {
  late final TabBranchResetGuard<AppTab> _branchResetGuard;
  TabReselectController<AppTab>? _controller;
  var _isConfirmationShowing = false;

  @override
  void initState() {
    super.initState();
    _branchResetGuard = TabBranchResetGuard<AppTab>(
      tab: AppTab.logs,
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
    if (context.read<LogsBloc>().state.editor.isOpen) {
      context.read<LogsBloc>().add(const LogsDraftDiscarded());
    }
    onDiscard();
  }

  Future<bool> _requestBranchReset() async {
    final canDiscard = await _canDiscard();
    if (canDiscard && mounted) {
      if (context.read<LogsBloc>().state.editor.isOpen) {
        context.read<LogsBloc>().add(const LogsDraftDiscarded());
      }
    }
    return canDiscard;
  }

  Future<bool> _canDiscard() async {
    if (!context.read<LogsBloc>().state.isDraftDirty) {
      return true;
    }
    if (_isConfirmationShowing) {
      return false;
    }
    setState(() => _isConfirmationShowing = true);
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.logEntryDiscardConfirmationTitle,
      content: l10n.logEntryDiscardConfirmationDescription,
      cancelLabel: l10n.logEntryDiscardCancelAction,
      confirmLabel: l10n.logEntryDiscardAction,
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
