import 'package:material_ui/material_ui.dart';

/// The scene illustration's own colours, chosen by brightness. They belong to
/// the illustration, not to the design system. Far layers sit close to the sky
/// and near layers are deeper, which is the atmospheric perspective.
enum ScenePalette {
  day(
    sky: Color(0xFFE3F2F3),
    sun: Color(0xFFFFD45C),
    cloud: Color(0xFFFFFFFF),
    bird: Color(0xFF7FB3BA),
    farHills: Color(0xFFC6E4E7),
    midHills: Color(0xFF9FD2D8),
    backWater: Color(0xFF6DBDC7),
    shimmer: Color(0xFFFFFFFF),
    nearWater: Color(0xFF2A98A4),
    closestWater: Color(0xFF0E7474),
    foam: Color(0xFFBFE6EA),
    ink: Color(0xFF0F5D5D),
  ),
  night(
    sky: Color(0xFF0D2A30),
    sun: Color(0xFFE7F5F5),
    cloud: Color(0xFF1A3F46),
    bird: Color(0xFF4F7F86),
    farHills: Color(0xFF143840),
    midHills: Color(0xFF1A4950),
    backWater: Color(0xFF1F5E66),
    shimmer: Color(0xFF7FD3D3),
    nearWater: Color(0xFF13707A),
    closestWater: Color(0xFF0B555D),
    foam: Color(0xFF5CC8C8),
    ink: Color(0xFFE7F5F5),
  );

  new({
    required this.sky,
    required this.sun,
    required this.cloud,
    required this.bird,
    required this.farHills,
    required this.midHills,
    required this.backWater,
    required this.shimmer,
    required this.nearWater,
    required this.closestWater,
    required this.foam,
    required this.ink,
  });

  static ScenePalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? night : day;

  bool get isNight => this == night;

  final Color sky;
  final Color sun;
  final Color cloud;
  final Color bird;
  final Color farHills;
  final Color midHills;
  final Color backWater;
  final Color shimmer;
  final Color nearWater;
  final Color closestWater;
  final Color foam;

  /// Text colour for the heading drawn over the sky.
  final Color ink;
}
