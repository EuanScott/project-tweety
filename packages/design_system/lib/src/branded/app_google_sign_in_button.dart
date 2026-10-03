import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../adaptive/app_design_platform.dart';
import '../adaptive/app_loading_indicator.dart';

/// Google's "Sign in with Google" button, built to Google's branding
/// guidelines with the official "G" mark from Google's asset kit.
///
/// This is a branded control, so it looks the same on Material and Cupertino.
/// Only the press feedback and the side padding follow the platform, as
/// Google's guidelines specify different padding for Android and iOS.
///
/// The caller passes localized [label] and [loadingLabel]. A null [onPressed]
/// disables the button. While [loading], the button shows
/// [AppLoadingIndicator] and [loadingLabel] in place of the mark and [label],
/// and it ignores presses.
class const AppGoogleSignInButton({
  required final String label,
  required final String loadingLabel,
  required final VoidCallback? onPressed,
  final bool loading = false,
  super.key,
}) extends StatelessWidget {
  /// Finds the decorated surface that carries the fill and border.
  @visibleForTesting
  static const ValueKey<String> surfaceKey = ValueKey(
    'app-google-sign-in-button-surface',
  );

  /// Finds the official Google "G" mark.
  @visibleForTesting
  static const ValueKey<String> markKey = ValueKey(
    'app-google-sign-in-button-mark',
  );

  static const _markAsset = 'assets/google/google_g_mark.png';
  static const _markSize = 20.0;
  static const _minHeight = 48.0;
  static const _radius = BorderRadius.all(Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !loading;
    final isCupertino = AppDesignPlatform.of(context).isCupertino;
    final colors = Theme.of(context).brightness == Brightness.dark
        ? _GoogleButtonColors.dark
        : _GoogleButtonColors.light;
    final spacing = isCupertino
        ? _GoogleButtonSpacing.ios
        : _GoogleButtonSpacing.android;
    final textStyle = GoogleFonts.googleSans(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: colors.text,
    );

    final surface = DecoratedBox(
      key: surfaceKey,
      decoration: BoxDecoration(
        color: colors.fill,
        border: Border.all(color: colors.stroke),
        borderRadius: _radius,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: spacing.start,
            end: spacing.end,
          ),
          child: Center(
            widthFactor: 1,
            child: Row(
              mainAxisSize: .min,
              children: [
                SizedBox.square(
                  dimension: _markSize,
                  child: loading
                      ? const AppLoadingIndicator()
                      : Image.asset(
                          _markAsset,
                          key: markKey,
                          package: 'design_system',
                          width: _markSize,
                          height: _markSize,
                        ),
                ),
                SizedBox(width: spacing.afterMark),
                Flexible(
                  child: Text(
                    loading ? loadingLabel : label,
                    style: textStyle,
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: true,
      enabled: isEnabled,
      label: loading ? loadingLabel : label,
      onTap: isEnabled ? onPressed : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.7,
        child: isCupertino
            ? _CupertinoPressFade(
                onPressed: isEnabled ? onPressed : null,
                child: surface,
              )
            : Stack(
                fit: StackFit.passthrough,
                children: [
                  surface,
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      borderRadius: _radius,
                      clipBehavior: .antiAlias,
                      child: InkWell(
                        onTap: isEnabled ? onPressed : null,
                        borderRadius: _radius,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Cupertino press feedback: the button dims while pressed, as
/// `CupertinoButton` does, without changing the size the caller gives it.
class _CupertinoPressFade extends StatefulWidget {
  const new({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<_CupertinoPressFade> createState() => _CupertinoPressFadeState();
}

class _CupertinoPressFadeState extends State<_CupertinoPressFade> {
  bool _isPressed = false;

  void _setPressed(bool isPressed) {
    if (_isPressed != isPressed) {
      setState(() => _isPressed = isPressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: onPressed == null ? null : (_) => _setPressed(true),
      onTapUp: onPressed == null ? null : (_) => _setPressed(false),
      onTapCancel: onPressed == null ? null : () => _setPressed(false),
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: _isPressed ? 0.4 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

enum _GoogleButtonColors {
  light(
    fill: Color(0xFFFFFFFF),
    stroke: Color(0xFF747775),
    text: Color(0xFF1F1F1F),
  ),
  dark(
    fill: Color(0xFF131314),
    stroke: Color(0xFF8E918F),
    text: Color(0xFFE3E3E3),
  );

  new({
    required this.fill,
    required this.stroke,
    required this.text,
  });

  final Color fill;
  final Color stroke;
  final Color text;
}

enum _GoogleButtonSpacing {
  android(start: 12, afterMark: 10, end: 12),
  ios(start: 16, afterMark: 12, end: 16);

  new({
    required this.start,
    required this.afterMark,
    required this.end,
  });

  final double start;
  final double afterMark;
  final double end;
}
