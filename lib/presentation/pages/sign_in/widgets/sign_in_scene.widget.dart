part of '../sign_in.page.dart';

/// The water scene with Dash, moving with device tilt and with [scrollOffset].
class _SignInScene extends StatelessWidget {
  const new({
    required this.compositionSize,
    required this.fadeExtent,
    required this.fadeAxis,
    required this.isSplit,
    this.scrollOffset = 0,
    super.key,
  });

  final Size compositionSize;
  final double fadeExtent;
  final Axis fadeAxis;
  final bool isSplit;
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return WaterScene(
      compositionSize: compositionSize,
      fadeExtent: fadeExtent,
      fadeAxis: fadeAxis,
      keepsSkyClear: isSplit,
      tilt: context.read<SceneTiltCubit>(),
      scrollOffset: scrollOffset,
      subject: Image.asset(
        'assets/app_icon/dash.png',
        fit: BoxFit.contain,
        semanticLabel: AppLocalizations.of(context)!.signInSceneDescription,
      ),
    );
  }
}
