import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_ui/material_ui.dart';

part 'scene_frame.model.freezed.dart';

/// Where a scene layout puts its scene: the composition box, and how far the
/// scene runs on past it along [fadeAxis] to fade into the page.
@freezed
abstract class SceneFrame with _$SceneFrame {
  const factory({
    required Size compositionSize,
    required double fadeExtent,
    required Axis fadeAxis,

    /// How far the compact layout has scrolled the scene away, for parallax.
    @Default(0) double scrollOffset,
  }) = _SceneFrame;
}
