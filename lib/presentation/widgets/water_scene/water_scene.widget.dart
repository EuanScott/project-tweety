import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'scene_palette.model.dart';
import 'scene_tilt.cubit.dart';

export 'scene_palette.model.dart';
export 'scene_tilt.cubit.dart';

/// How far each layer moves. Far layers move less, which reads as depth.
enum _SceneLayer {
  sky(scrollFactor: 0.70, maxTiltShift: 2),
  far(scrollFactor: 0.55, maxTiltShift: 4),
  mid(scrollFactor: 0.42, maxTiltShift: 6),
  back(scrollFactor: 0.30, maxTiltShift: 9),
  subject(scrollFactor: 0.18, maxTiltShift: 11),
  front(scrollFactor: 0, maxTiltShift: 16);

  new({required this.scrollFactor, required this.maxTiltShift});

  final double scrollFactor;
  final double maxTiltShift;

  /// Starting strength of the tilt effect; tune on a device.
  static const tiltStrength = 1.0;

  Offset shift({required Offset tilt, required double scrollOffset}) {
    final tiltShift = maxTiltShift * tiltStrength;

    return Offset(
      -tilt.dx * tiltShift,
      -tilt.dy * tiltShift * 0.5 + scrollOffset * scrollFactor,
    );
  }
}

/// A wavy horizon at [y], filled down to the bottom of the scene.
class const _Wave({
  required final double y,
  required final double amplitude,
  required final double wavelength,
  required final double phase,
}) {
  double yAt(double x) {
    return y +
        amplitude * math.sin(2 * math.pi * x / wavelength + phase) +
        0.35 *
            amplitude *
            math.sin(2 * math.pi * x / (0.43 * wavelength) + 1.7 * phase);
  }
}

/// A short rounded bar of shimmer or foam, [below] a wave's line.
class const _Bar({
  required final double x,
  required final double below,
  required final double width,
});

/// Where everything sits in a composition box of [width] × [height].
class _SceneGeometry {
  new({required this.width, required this.height, required this.keepsSkyClear});

  final double width;
  final double height;

  /// Keeps the sun, clouds and birds clear of a large heading at the top.
  final bool keepsSkyClear;

  double get subjectSize => math.min(0.58 * height, 0.72 * width);

  double get baseline => 0.84 * height;

  Rect get subjectRect => Rect.fromLTWH(
    (width - subjectSize) / 2,
    baseline - 0.80 * subjectSize,
    subjectSize,
    subjectSize,
  );

  _Wave _wave(double line, double amplitude, double wavelength, double phase) {
    final s = subjectSize;

    return _Wave(
      y: baseline + line * s,
      amplitude: amplitude * s,
      wavelength: wavelength * width,
      phase: phase,
    );
  }

  _Wave get farHills => _wave(-0.62, 0.06, 0.9, 0.4);

  _Wave get midHills => _wave(-0.45, 0.045, 0.6, 2.1);

  _Wave get backWater => _wave(-0.28, 0.018, 0.25, 1);

  _Wave get nearWater => _wave(-0.07, 0.025, 0.33, 0.3);

  _Wave get closestWater => _wave(0.10, 0.03, 0.45, 1.9);

  double get sunRadius => math.max(22, 0.07 * width);

  Offset get sunCentre {
    final y = math.min(0.2 * height, farHills.y - 0.25 * subjectSize);

    return Offset(
      0.78 * width,
      keepsSkyClear ? math.max(y, 250 + sunRadius) : y,
    );
  }

  double get cloudMinTop => keepsSkyClear ? 210 : 20;

  /// Only the split layout keeps birds clear of the heading.
  double get birdMinTop => keepsSkyClear ? 240 : 0;

  /// The heading and subtitle over the sky in the split layout.
  Rect? get headingArea => keepsSkyClear
      ? Rect.fromLTWH(40, 56, math.min(width - 80, 420), 130)
      : null;

  /// The soft-edged wavy bands of [background] that fade the scene out over
  /// [extent] past its edge, nearest band first. They and their blur stay
  /// inside the fade, so the scene keeps its full strength and the last band
  /// is solid by the fade's far edge.
  _WavesPainter fadePainter(Axis axis, double extent, Color background) {
    final isVertical = axis == Axis.vertical;
    final start = isVertical ? height : width;
    final across = isVertical ? width : height;
    final amplitude = 0.08 * extent;
    final blur = 0.06 * extent;
    // A wave reaches up to 1.35 × its amplitude from its line, and a blur is
    // visible up to about 3 sigma past its edge.
    final reach = 1.35 * amplitude + 3 * blur;
    final top = start + reach;
    final span = extent - 2 * reach;

    // A sideways fade is laid out as if it ran down, then painted transposed.
    return _WavesPainter(
      transposed: !isVertical,
      fills: [
        for (final (i, band) in _fadeBands.indexed)
          _WaveFill(
            wave: _Wave(
              y: top + span * i / (_fadeBands.length - 1),
              amplitude: amplitude,
              wavelength: band.wavelength * across,
              phase: band.phase,
            ),
            color: background.withValues(alpha: band.alpha),
            blur: blur,
          ),
      ],
    );
  }
}

/// The layered water scene: sky, hills, water, and an optional [subject]
/// standing in it.
///
/// The composition box is [compositionSize]. The scene runs on past it by
/// [fadeExtent] along [fadeAxis] (down, or toward the end edge) and fades to
/// [fadeColor] there, which defaults to the page background. The fade is
/// soft-edged wavy bands, like the water.
///
/// Pass a [tilt] cubit to let each layer move on its own with device tilt and
/// with [scrollOffset]; Reduce Motion stops both. Without one the scene is
/// still.
class WaterScene extends StatefulWidget {
  const new({
    required this.compositionSize,
    required this.fadeExtent,
    required this.fadeAxis,
    this.keepsSkyClear = false,
    this.subject,
    this.fadeColor,
    this.tilt,
    this.scrollOffset = 0,
    super.key,
  });

  /// One of `sky`, `far`, `mid`, `back`, `subject` or `front`.
  @visibleForTesting
  static ValueKey<String> layerKey(String layer) =>
      ValueKey('water-scene-layer-$layer');

  final Size compositionSize;
  final double fadeExtent;
  final Axis fadeAxis;

  /// Keeps the sun, clouds and birds clear of a large heading at the top.
  final bool keepsSkyClear;

  /// Stands in the water between the back and front layers.
  final Widget? subject;

  final Color? fadeColor;
  final SceneTiltCubit? tilt;
  final double scrollOffset;

  @override
  State<WaterScene> createState() => _WaterSceneState();
}

class _WaterSceneState extends State<WaterScene> {
  late final AppLifecycleListener _lifecycle;
  bool _isAppResumed = true;
  bool _isOnScreen = true;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    _isAppResumed = state == null || state == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        _isAppResumed = state == AppLifecycleState.resumed;
        _reportConditions();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _isOnScreen = TickerMode.valuesOf(context).enabled;
    _reportConditions();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _reportConditions() {
    widget.tilt?.sceneConditionsChanged(
      isAppResumed: _isAppResumed,
      isOnScreen: _isOnScreen,
      reduceMotion: _reduceMotion,
    );
  }

  Widget _layer(_SceneLayer layer, Widget child) {
    final boundary = RepaintBoundary(
      key: WaterScene.layerKey(layer.name),
      child: child,
    );
    final tilt = widget.tilt;
    if (tilt == null) {
      return boundary;
    }

    final scrollOffset = _reduceMotion ? 0.0 : widget.scrollOffset;

    return BlocBuilder<SceneTiltCubit, Offset>(
      bloc: tilt,
      builder: (context, tilt) => Transform.translate(
        offset: layer.shift(tilt: tilt, scrollOffset: scrollOffset),
        child: boundary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ScenePalette.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final composition = widget.compositionSize;
    final isVertical = widget.fadeAxis == Axis.vertical;
    final size = isVertical
        ? Size(composition.width, composition.height + widget.fadeExtent)
        : Size(composition.width + widget.fadeExtent, composition.height);
    final geometry = _SceneGeometry(
      width: composition.width,
      height: composition.height,
      keepsSkyClear: widget.keepsSkyClear,
    );
    final background =
        widget.fadeColor ?? Theme.of(context).scaffoldBackgroundColor;

    // Painters draw left to right; right-to-left mirrors them, so in the split
    // layout the fade still runs toward the end edge.
    Widget painted(CustomPainter painter) => Transform.flip(
      flipX: isRtl,
      child: CustomPaint(size: size, painter: painter),
    );

    final subjectRect = geometry.subjectRect;

    return SizedBox.fromSize(
      size: size,
      child: ClipRect(
        child: Stack(
          children: [
            _layer(
              _SceneLayer.sky,
              painted(_SkyPainter(geometry: geometry, palette: palette)),
            ),
            _layer(
              _SceneLayer.far,
              painted(
                _WavesPainter(
                  fills: [
                    _WaveFill(wave: geometry.farHills, color: palette.farHills),
                  ],
                ),
              ),
            ),
            _layer(
              _SceneLayer.mid,
              painted(
                _WavesPainter(
                  fills: [
                    _WaveFill(wave: geometry.midHills, color: palette.midHills),
                  ],
                ),
              ),
            ),
            _layer(
              _SceneLayer.back,
              painted(
                _WavesPainter(
                  fills: [
                    _WaveFill(
                      wave: geometry.backWater,
                      color: palette.backWater,
                      bars: _BarRow(
                        color: palette.shimmer.withValues(alpha: 0.6),
                        height: 2,
                        bars: _shimmer(geometry),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.subject case final subject?)
              PositionedDirectional(
                start: subjectRect.left,
                top: subjectRect.top,
                width: subjectRect.width,
                height: subjectRect.height,
                child: _layer(_SceneLayer.subject, subject),
              ),
            _layer(
              _SceneLayer.front,
              painted(
                _WavesPainter(
                  fills: [
                    _WaveFill(
                      wave: geometry.nearWater,
                      color: palette.nearWater,
                      bars: _BarRow(
                        color: palette.foam.withValues(alpha: 0.7),
                        height: 3,
                        bars: _nearFoam(geometry),
                      ),
                    ),
                    _WaveFill(
                      wave: geometry.closestWater,
                      color: palette.closestWater,
                      bars: _BarRow(
                        color: palette.foam.withValues(alpha: 0.55),
                        height: 3,
                        bars: _closestFoam(geometry),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            painted(
              geometry.fadePainter(
                widget.fadeAxis,
                widget.fadeExtent,
                background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Bar> _shimmer(_SceneGeometry g) {
    final w = g.width;
    final s = g.subjectSize;

    return [
      _Bar(x: 0.08 * w, below: 0.06 * s, width: 0.07 * w),
      _Bar(x: 0.30 * w, below: 0.12 * s, width: 0.05 * w),
      _Bar(x: 0.66 * w, below: 0.05 * s, width: 0.06 * w),
      _Bar(x: 0.86 * w, below: 0.13 * s, width: 0.05 * w),
    ];
  }

  List<_Bar> _nearFoam(_SceneGeometry g) {
    final w = g.width;
    final s = g.subjectSize;

    return [
      _Bar(x: 0.18 * w, below: 0.05 * s, width: 0.09 * w),
      _Bar(x: 0.58 * w, below: 0.08 * s, width: 0.07 * w),
      _Bar(x: 0.78 * w, below: 0.03 * s, width: 0.08 * w),
    ];
  }

  List<_Bar> _closestFoam(_SceneGeometry g) {
    final w = g.width;
    final s = g.subjectSize;

    return [
      _Bar(x: 0.06 * w, below: 0.05 * s, width: 0.10 * w),
      _Bar(x: 0.44 * w, below: 0.09 * s, width: 0.08 * w),
      _Bar(x: 0.82 * w, below: 0.06 * s, width: 0.09 * w),
    ];
  }
}

/// The fade's bands, top to bottom. Each band fills down to the bottom, so the
/// opacities stack to 35%, 65%, 87% and then 100% — the same steps as
/// [SceneFade].
const List<({double wavelength, double phase, double alpha})> _fadeBands = [
  (wavelength: 0.45, phase: 0.6, alpha: 0.35),
  (wavelength: 0.33, phase: 2.2, alpha: 0.30 / 0.65),
  (wavelength: 0.40, phase: 1.1, alpha: 0.22 / 0.35),
  (wavelength: 0.28, phase: 2.9, alpha: 1),
];

/// Fades into [background] with eased stops, so a scene or a scrolled
/// edge blends into what sits behind it.
class const SceneFade({
  required final Color background,
  required final AlignmentGeometry begin,
  required final AlignmentGeometry end,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [
              for (final alpha in const [0.0, 0.35, 0.65, 0.87, 1.0])
                background.withValues(alpha: alpha),
            ],
            stops: const [0, 0.2, 0.45, 0.7, 1],
          ),
        ),
      ),
    );
  }
}

/// Every layer is drawn this far past each edge, so a moved layer never shows
/// an edge.
const double _sceneBleed = 24;

class const _SkyPainter({
  required final _SceneGeometry geometry,
  required final ScenePalette palette,
}) extends CustomPainter {
  static const List<({double x, double y, double radius, double alpha})>
  _stars = [
    (x: 0.12, y: 0.08, radius: 1.6, alpha: 0.7),
    (x: 0.30, y: 0.16, radius: 1.2, alpha: 0.5),
    (x: 0.55, y: 0.06, radius: 2.2, alpha: 0.6),
    (x: 0.66, y: 0.24, radius: 1.4, alpha: 0.55),
    (x: 0.90, y: 0.33, radius: 1.8, alpha: 0.65),
    (x: 0.20, y: 0.30, radius: 1.2, alpha: 0.5),
    (x: 0.42, y: 0.27, radius: 2.0, alpha: 0.6),
  ];

  static const List<({double x, double y, double halfWidth})> _birds = [
    (x: 0.36, y: 0.11, halfWidth: 9.0),
    (x: 0.42, y: 0.08, halfWidth: 7.0),
    (x: 0.47, y: 0.13, halfWidth: 6.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = geometry.width;
    final h = geometry.height;

    canvas.drawRect(
      Rect.fromLTRB(
        -_sceneBleed,
        -_sceneBleed,
        size.width + _sceneBleed,
        size.height + _sceneBleed,
      ),
      Paint()..color = palette.sky,
    );

    if (palette.isNight) {
      _paintStars(canvas);
    }
    _paintSunOrMoon(canvas);
    _paintCloud(canvas, centreX: 0.20 * w, top: 0.14 * h, width: 0.26 * w);
    _paintCloud(canvas, centreX: 0.55 * w, top: 0.24 * h, width: 0.18 * w);
    if (!palette.isNight) {
      _paintBirds(canvas);
    }
  }

  void _paintStars(Canvas canvas) {
    final headingArea = geometry.headingArea;
    final farHills = geometry.farHills;

    for (final star in _stars) {
      final centre = Offset(star.x * geometry.width, star.y * geometry.height);
      final isBehindHeading = headingArea?.contains(centre) ?? false;
      final isBelowHills = centre.dy > farHills.yAt(centre.dx) - star.radius;
      if (isBehindHeading || isBelowHills) {
        continue;
      }

      canvas.drawCircle(
        centre,
        star.radius,
        Paint()..color = palette.sun.withValues(alpha: star.alpha),
      );
    }
  }

  void _paintSunOrMoon(Canvas canvas) {
    final centre = geometry.sunCentre;
    final r = geometry.sunRadius;

    if (!palette.isNight) {
      canvas
        ..drawCircle(
          centre,
          1.7 * r,
          Paint()..color = palette.sun.withValues(alpha: 0.35),
        )
        ..drawCircle(
          centre,
          r,
          Paint()..color = palette.sun.withValues(alpha: 0.9),
        );
      return;
    }

    canvas
      ..drawCircle(
        centre,
        0.8 * r,
        Paint()..color = palette.sun.withValues(alpha: 0.9),
      )
      ..drawCircle(
        centre + Offset(0.35 * r, -0.2 * r),
        0.7 * r,
        Paint()..color = palette.sky,
      );
  }

  void _paintCloud(
    Canvas canvas, {
    required double centreX,
    required double top,
    required double width,
  }) {
    final left = centreX - width / 2;
    final rise = 0.1 * width;
    // The top pill sits above the main one, so it is the one kept clear.
    final mainTop = math.max(top, geometry.cloudMinTop + rise);
    final pillHeight = 0.18 * width;
    final topWidth = 0.45 * width;
    final paint = Paint()..color = palette.cloud.withValues(alpha: 0.75);

    // Draw both pills into one layer so their overlap is not doubled.
    canvas
      ..saveLayer(null, paint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, mainTop, width, pillHeight),
          Radius.circular(pillHeight / 2),
        ),
        Paint()..color = palette.cloud,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + 0.18 * width,
            mainTop - rise,
            topWidth,
            pillHeight,
          ),
          Radius.circular(pillHeight / 2),
        ),
        Paint()..color = palette.cloud,
      )
      ..restore();
  }

  void _paintBirds(Canvas canvas) {
    final paint = Paint()
      ..color = palette.bird
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final bird in _birds) {
      final x = bird.x * geometry.width;
      final y = math.max(bird.y * geometry.height, geometry.birdMinTop);
      final hw = bird.halfWidth;
      final dip = 0.45 * hw;
      final path = Path()
        ..moveTo(x - hw, y)
        ..quadraticBezierTo(x - 0.4 * hw, y, x, y + dip)
        ..quadraticBezierTo(x + 0.4 * hw, y, x + hw, y);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) =>
      oldDelegate.palette != palette ||
      oldDelegate.geometry.width != geometry.width ||
      oldDelegate.geometry.height != geometry.height ||
      oldDelegate.geometry.keepsSkyClear != geometry.keepsSkyClear;
}

/// A row of shimmer or foam bars under a wave's line.
class const _BarRow({
  required final Color color,
  required final double height,
  required final List<_Bar> bars,
});

/// One wave filled down to the bottom, with the bars that sit on it. A [blur]
/// above zero softens the wave's edge.
class const _WaveFill({
  required final _Wave wave,
  required final Color color,
  final _BarRow? bars,
  final double blur = 0,
});

/// One or more wave fills, back to front. Each wave's bars sit on that wave,
/// under the next one.
///
/// When [transposed], x and y swap, so waves that run across the width run
/// down the height instead and fill toward the end edge.
class const _WavesPainter({
  required final List<_WaveFill> fills,
  final bool transposed = false,
}) extends CustomPainter {
  static const _step = 4.0;

  static final Float64List _transpose = Float64List.fromList(const [
    0, 1, 0, 0, //
    1, 0, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 1, //
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    if (transposed) {
      canvas
        ..save()
        ..transform(_transpose);
      _paintFills(canvas, size.flipped);
      canvas.restore();
    } else {
      _paintFills(canvas, size);
    }
  }

  void _paintFills(Canvas canvas, Size size) {
    final bottom = size.height + _sceneBleed;
    final right = size.width + _sceneBleed;

    for (final fill in fills) {
      final wave = fill.wave;
      final path = Path()
        ..moveTo(-_sceneBleed, bottom)
        ..lineTo(-_sceneBleed, wave.yAt(-_sceneBleed));
      for (var x = -_sceneBleed + _step; x < right; x += _step) {
        path.lineTo(x, wave.yAt(x));
      }
      path
        ..lineTo(right, wave.yAt(right))
        ..lineTo(right, bottom)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = fill.color
          ..maskFilter = fill.blur > 0
              ? MaskFilter.blur(BlurStyle.normal, fill.blur)
              : null,
      );

      final bars = fill.bars;
      if (bars != null) {
        _paintBars(canvas, wave, bars);
      }
    }
  }

  void _paintBars(Canvas canvas, _Wave wave, _BarRow row) {
    final paint = Paint()..color = row.color;

    for (final bar in row.bars) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bar.x, wave.y + bar.below, bar.width, row.height),
          Radius.circular(row.height / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) {
    if (oldDelegate.transposed != transposed ||
        oldDelegate.fills.length != fills.length) {
      return true;
    }
    for (var i = 0; i < fills.length; i++) {
      final previous = oldDelegate.fills[i];
      final current = fills[i];
      if (previous.color != current.color ||
          previous.blur != current.blur ||
          previous.bars?.color != current.bars?.color ||
          previous.wave.y != current.wave.y ||
          previous.wave.amplitude != current.wave.amplitude ||
          previous.wave.wavelength != current.wave.wavelength) {
        return true;
      }
    }

    return false;
  }
}
