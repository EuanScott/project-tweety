import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/data/repositories/auth/profile.model.dart';
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/widgets/app_modal.widget.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

import 'account.cubit.dart';
import 'account_avatar.widget.dart';

/// Opens the account modal for the [AccountCubit] above [context].
///
/// Phones get a sheet at 90% of the height. Expanded surfaces get a centred
/// window that fits its content; on an open foldable it stays on one side of
/// the hinge.
Future<void> showAccountModal(BuildContext context) {
  final cubit = context.read<AccountCubit>();
  // Read before the route opens: the dialog route may narrow the media data
  // to one side of a fold.
  final isWindowed = DisplayMetrics.isExpandedSurface(MediaQuery.of(context));

  return AppModal.page<void>(
    context: context,
    // The modal pads its own bottom edge, so its background reaches the screen
    // edge.
    useSafeArea: false,
    expandToMaxHeight: !isWindowed,
    child: BlocProvider.value(
      value: cubit,
      child: AccountModal(isWindowed: isWindowed),
    ),
  );
}

/// The signed-in person's Profile over the water scene, with sign-out at the
/// bottom.
///
/// Any Profile field can be missing; the modal says so plainly rather than
/// leave a gap. When the content is taller than the modal, all of it scrolls.
class AccountModal extends StatelessWidget {
  const new({required this.isWindowed, super.key});

  /// Whether the modal is a centred window rather than a sheet.
  final bool isWindowed;

  @visibleForTesting
  static const ValueKey<String> headingKey = ValueKey('account-heading');

  @visibleForTesting
  static const ValueKey<String> phoneLineKey = ValueKey('account-phone');

  @visibleForTesting
  static const ValueKey<String> emailLineKey = ValueKey('account-email');

  @visibleForTesting
  static const ValueKey<String> emailStatusKey = ValueKey(
    'account-email-status',
  );

  static const _windowMaxWidth = 440.0;

  /// The Material sheet's native drag handle sits above the content, in a
  /// strip this tall.
  static const double _materialDragHandleHeight = kMinInteractiveDimension;

  @override
  Widget build(BuildContext context) {
    final profile = context.select((AccountCubit cubit) => cubit.state.profile);
    final colorScheme = Theme.of(context).colorScheme;
    final isCupertino = AppDesignPlatform.of(context).isCupertino;
    // Each band is as tall as the design's; on the Material sheet that height
    // includes the drag handle.
    final bandHeight = switch ((isWindowed, isCupertino)) {
      (true, _) => 200.0,
      (false, true) => 230.0,
      (false, false) => 250.0 - _materialDragHandleHeight,
    };
    final bottomInset = isWindowed ? 0.0 : MediaQuery.paddingOf(context).bottom;

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gutter = width < 360 ? 20.0 : 24.0;

        return ColoredBox(
          color: colorScheme.surface,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.minHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    _AccountHeader(
                      profile: profile,
                      width: width,
                      bandHeight: bandHeight,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: .symmetric(horizontal: gutter),
                      child: _AccountIdentity(profile: profile),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: .symmetric(horizontal: gutter),
                      child: _AccountDetails(profile: profile),
                    ),
                    const SizedBox(height: 32),
                    const Spacer(),
                    Padding(
                      padding: .fromLTRB(gutter, 0, gutter, 24 + bottomInset),
                      child: const _AccountSignOut(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!isWindowed) {
      return content;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _windowMaxWidth),
      child: content,
    );
  }
}

/// The scene band with the title over the sky and the photo overlapping its
/// bottom edge.
class const _AccountHeader({
  required final Profile profile,
  required final double width,
  required final double bandHeight,
}) extends StatelessWidget {
  static const _photoSize = 96.0;
  static const _ringWidth = 4.0;

  /// How far the photo's centre sits above the band's bottom edge.
  static const _photoLift = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const ringedSize = _photoSize + 2 * _ringWidth;
    const photoTopFromBandBottom = _photoLift + ringedSize / 2;

    return SizedBox(
      height: bandHeight - photoTopFromBandBottom + ringedSize,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bandHeight,
            child: WaterScene(
              compositionSize: Size(width, 0.8 * bandHeight),
              fadeExtent: 0.2 * bandHeight,
              fadeAxis: Axis.vertical,
              fadeColor: colorScheme.surface,
            ),
          ),
          Positioned(
            // Level with the close button on the Cupertino sheet and the
            // window; at the top of the band, under the handle, on the
            // Material sheet.
            top: 4,
            height: 48,
            left: 56,
            right: 56,
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.accountTitle,
                textAlign: .center,
                maxLines: 1,
                overflow: .ellipsis,
                style: theme.textTheme.safeTitleMedium.copyWith(
                  fontSize: 17,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: ScenePalette.of(context).ink,
                ),
              ),
            ),
          ),
          Positioned(
            top: bandHeight - photoTopFromBandBottom,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: .circle,
                ),
                child: Padding(
                  padding: const .all(_ringWidth),
                  child: AccountAvatar(profile: profile, size: _photoSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The heading, the phone line and the email line.
///
/// The heading is the name, else the email, else "Your Account". The email
/// line shows only under a name, so the email never appears twice.
class const _AccountIdentity({required final Profile profile})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = profile.knownDisplayName;
    final email = profile.knownEmail;
    final emailLine = name == null ? null : email;

    return Column(
      children: [
        Text(
          name ?? email ?? l10n.accountFallbackHeading,
          key: AccountModal.headingKey,
          textAlign: .center,
          style: theme.textTheme.safeHeadlineSmall.copyWith(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.knownPhoneNumber ?? l10n.accountNoPhone,
          key: AccountModal.phoneLineKey,
          textAlign: .center,
          style: theme.textTheme.safeBodyLarge.copyWith(
            fontSize: 16,
            height: 1.4,
            color: colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (emailLine != null) ...[
          const SizedBox(height: 4),
          Text(
            emailLine,
            key: AccountModal.emailLineKey,
            textAlign: .center,
            style: theme.textTheme.safeBodyMedium.copyWith(
              fontSize: 14,
              height: 1.4,
              color: _mutedOnSurface(theme),
            ),
          ),
        ],
      ],
    );
  }
}

/// The raised card with the email status and the sign-in provider.
class const _AccountDetails({required final Profile profile})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = DesignStatusColors.of(theme);
    final (icon, iconColor, emailStatus) = switch (profile) {
      Profile(knownEmail: null) => (
        Icons.remove,
        _mutedOnSurface(theme),
        l10n.accountNoEmail,
      ),
      Profile(isEmailVerified: true) => (
        Icons.check_circle,
        status.success,
        l10n.accountEmailVerified,
      ),
      Profile() => (
        Icons.warning_amber_rounded,
        status.warning,
        l10n.accountEmailNotVerified,
      ),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          _AccountDetailRow(
            label: l10n.accountEmailLabel,
            value: Row(
              spacing: 8,
              children: [
                ExcludeSemantics(
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                Expanded(
                  child: _AccountDetailValue(
                    emailStatus,
                    key: AccountModal.emailStatusKey,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          _AccountDetailRow(
            label: l10n.accountSignedInWithLabel,
            value: _AccountDetailValue(l10n.accountProviderGoogle),
          ),
        ],
      ),
    );
  }
}

/// A 12 px label above its value.
class const _AccountDetailRow({
  required final String label,
  required final Widget value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 4,
        children: [
          Text(
            label,
            style: theme.textTheme.safeBodySmall.copyWith(
              fontSize: 12,
              height: 1.3,
              color: _mutedOnSurface(theme),
            ),
          ),
          value,
        ],
      ),
    );
  }
}

class const _AccountDetailValue(final String text, {super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.safeBodyLarge.copyWith(
        fontSize: 16,
        height: 1.4,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

/// The sign-out button and its footnote. Signing out asks once first.
class const _AccountSignOut() extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isSigningOut = context.select(
      (AccountCubit cubit) => cubit.state is AccountSigningOut,
    );

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: AppButton.secondary(
            onPressed: isSigningOut
                ? null
                : () => unawaited(_confirmSignOut(context)),
            child: isSigningOut
                ? Row(
                    mainAxisSize: .min,
                    spacing: 8,
                    children: [
                      const SizedBox.square(
                        dimension: 18,
                        child: AppLoadingIndicator(),
                      ),
                      Text(l10n.accountSigningOut),
                    ],
                  )
                : Text(l10n.accountSignOut),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.accountSignOutFootnote,
          textAlign: .center,
          style: theme.textTheme.safeBodySmall.copyWith(
            fontSize: 12,
            height: 1.4,
            color: _mutedOnSurface(theme),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AccountCubit>();

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: l10n.accountSignOutConfirmTitle,
      content: l10n.accountSignOutConfirmBody,
      cancelLabel: l10n.accountSignOutConfirmCancel,
      confirmLabel: l10n.accountSignOutConfirmAction,
    );
    if (confirmed) {
      await cubit.signOutRequested();
    }
  }
}

/// Secondary text and marks: `onSurface` at 60%, or 70% in dark mode so it
/// keeps its contrast on the dark sheet.
Color _mutedOnSurface(ThemeData theme) {
  final isDark = theme.brightness == Brightness.dark;

  return theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.6);
}
