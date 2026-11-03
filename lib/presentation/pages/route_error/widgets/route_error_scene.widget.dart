part of '../route_error.page.dart';

/// The design draws the scene on a 390 × 620 stage. Its content box is
/// 390 × 440, centred on the stage point (195, 300).
const Size _stageContent = Size(390, 440);
const Offset _stageCentre = Offset(195, 300);
const double _maxStageScale = 1.5;

/// The split layout keeps the scene clear of the panel's edges.
const EdgeInsets _splitStagePadding = EdgeInsets.symmetric(
  horizontal: 24,
  vertical: 64,
);

/// Where the compass sits on the stage.
const Offset _compassCentre = Offset(195, 440);

/// How the stage sits in a composition box: one scale, with the stage's
/// top-left corner at the origin.
typedef _StageFit = ({double scale, Offset origin});

/// Fits the content box inside [box] less [padding], at most 1.5×, centred.
_StageFit _fitStage(Size box, EdgeInsets padding) {
  final scale = math.max<double>(
    0,
    math.min(
      math.min(
        (box.width - padding.horizontal) / _stageContent.width,
        (box.height - padding.vertical) / _stageContent.height,
      ),
      _maxStageScale,
    ),
  );

  return (scale: scale, origin: box.center(Offset.zero) - _stageCentre * scale);
}

/// How far each layer moves with tilt. The compass stays fixed on the page:
/// its needle shows the real heading instead.
enum _MapLayer {
  rings(maxTiltShift: 2),
  farMap(maxTiltShift: 4),
  nearMap(maxTiltShift: 7),
  smallMap(maxTiltShift: 10),
  pin(maxTiltShift: 12);

  new({required this.maxTiltShift});

  final double maxTiltShift;

  Offset shift(Offset tilt) =>
      Offset(-tilt.dx * maxTiltShift, -tilt.dy * maxTiltShift * 0.5);
}

/// The colours the stage paints with.
typedef _MapColours = ({
  MapScenePalette map,
  Color sky,
  Color primary,
  Color onPrimary,
});

/// The "Off the map" scene: map rings in the sky, three floating map cards, a
/// pin with a "?", and a compass whose needle points to magnetic north.
///
/// The map layers move with device tilt, each its own distance, and float on
/// their own. Reduce Motion stops all of it, and the needle points up. The
/// scene is decoration, so screen readers skip it.
class _RouteErrorScene extends StatefulWidget {
  const new({required this.frame});

  final SceneFrame frame;

  @override
  State<_RouteErrorScene> createState() => _RouteErrorSceneState();
}

class _RouteErrorSceneState extends State<_RouteErrorScene>
    with SingleTickerProviderStateMixin {
  late final AppLifecycleListener _lifecycle;
  late final _ticker = createTicker(_onTick);
  final ValueNotifier<double?> _clock = ValueNotifier(null);
  _MapLabels? _labels;
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
    _updateMotion();
    _updateLabels();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _ticker.dispose();
    _clock.dispose();
    _labels?.dispose();
    super.dispose();
  }

  /// The tilt and the compass sensors run under the same conditions.
  void _reportConditions() {
    context.read<SceneTiltCubit>().sceneConditionsChanged(
      isAppResumed: _isAppResumed,
      isOnScreen: _isOnScreen,
      reduceMotion: _reduceMotion,
    );
    context.read<CompassHeadingCubit>().sceneConditionsChanged(
      isAppResumed: _isAppResumed,
      isOnScreen: _isOnScreen,
      reduceMotion: _reduceMotion,
    );
  }

  /// The ticker is muted while the page is off screen, so it only needs
  /// stopping for Reduce Motion.
  void _updateMotion() {
    if (_reduceMotion) {
      _ticker.stop();
      _clock.value = null;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    _clock.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  }

  void _updateLabels() {
    final theme = Theme.of(context);
    final labels = _MapLabels(
      base: theme.textTheme.safeBodyLarge,
      ink: MapScenePalette.of(context).ink,
      onPrimary: theme.colorScheme.onPrimary,
    );
    if (labels.matches(_labels)) {
      labels.dispose();
      return;
    }

    _labels?.dispose();
    _labels = labels;
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame;
    final composition = frame.compositionSize;
    final isVertical = frame.fadeAxis == Axis.vertical;
    final size = isVertical
        ? Size(composition.width, composition.height + frame.fadeExtent)
        : Size(composition.width + frame.fadeExtent, composition.height);
    final theme = Theme.of(context);
    final colours = (
      map: MapScenePalette.of(context),
      sky: ScenePalette.of(context).sky,
      primary: theme.colorScheme.primary,
      onPrimary: theme.colorScheme.onPrimary,
    );
    final fit = _fitStage(
      composition,
      isVertical ? EdgeInsets.zero : _splitStagePadding,
    );
    final labels = _labels!;
    final needleOrigin =
        fit.origin + _compassCentre * fit.scale - composition.center(.zero);

    Widget painted(String name, CustomPainter painter) => RepaintBoundary(
      key: RouteErrorPage.layerKey(name),
      child: CustomPaint(size: composition, painter: painter),
    );

    Widget layer(_MapLayer layer, Offset tilt, CustomPainter painter) =>
        Transform.translate(
          offset: layer.shift(tilt),
          child: painted(layer.name, painter),
        );

    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox.fromSize(
          size: size,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: colours.sky)),
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  width: composition.width,
                  height: composition.height,
                  child: BlocBuilder<SceneTiltCubit, Offset>(
                    builder: (context, tilt) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        layer(
                          .rings,
                          tilt,
                          _RingsPainter(fit: fit, colours: colours),
                        ),
                        layer(
                          .farMap,
                          tilt,
                          _FarMapPainter(
                            fit: fit,
                            colours: colours,
                            labels: labels,
                            clock: _clock,
                          ),
                        ),
                        layer(
                          .nearMap,
                          tilt,
                          _NearMapPainter(
                            fit: fit,
                            colours: colours,
                            clock: _clock,
                          ),
                        ),
                        layer(
                          .smallMap,
                          tilt,
                          _SmallMapPainter(
                            fit: fit,
                            colours: colours,
                            clock: _clock,
                          ),
                        ),
                        layer(
                          .pin,
                          tilt,
                          _PinPainter(
                            fit: fit,
                            colours: colours,
                            labels: labels,
                            clock: _clock,
                          ),
                        ),
                        painted(
                          'compass',
                          _CompassPainter(
                            fit: fit,
                            colours: colours,
                            labels: labels,
                          ),
                        ),
                        BlocBuilder<CompassHeadingCubit, double?>(
                          builder: (context, heading) => Transform.rotate(
                            key: RouteErrorPage.needleKey,
                            angle: -(heading ?? 0) * math.pi / 180,
                            origin: needleOrigin,
                            child: RepaintBoundary(
                              child: CustomPaint(
                                size: composition,
                                painter: _NeedlePainter(
                                  fit: fit,
                                  colours: colours,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isVertical)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: composition.height,
                    height: frame.fadeExtent,
                    child: SceneWavyFade(
                      axis: Axis.vertical,
                      background: theme.scaffoldBackgroundColor,
                    ),
                  )
                else
                  PositionedDirectional(
                    start: composition.width,
                    width: frame.fadeExtent,
                    top: 0,
                    bottom: 0,
                    child: SceneWavyFade(
                      axis: Axis.horizontal,
                      background: theme.scaffoldBackgroundColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The scene's slow ambient motion at [seconds] since it started, as the
/// design animates it. Without [seconds] the scene is still and every value
/// is at rest.
class const _Ambient(final double? seconds) {
  /// Dots along the route sit this far apart.
  static const double dotSpacing = 9.1;

  /// A card floating 5 units up and down, [period] seconds each way.
  /// [delay] seconds have already run when the scene starts.
  double float(double period, {bool reversed = false, double delay = 0}) {
    final seconds = this.seconds;
    if (seconds == null) {
      return 0;
    }

    final y = -5 + 10 * _alternate((seconds + delay) / period);
    return reversed ? -y : y;
  }

  /// How far the route's dots have marched forward, within one spacing.
  double get march {
    final seconds = this.seconds;
    return seconds == null ? 0 : (seconds / 1.6 * 18) % dotSpacing;
  }

  /// The pin's bob, 2.8 s a cycle: how far it lifts and how far it leans,
  /// in radians.
  ({double lift, double lean}) get bob {
    final seconds = this.seconds;
    if (seconds == null) {
      return (lift: 0, lean: 0);
    }

    final w = _alternate(seconds / 1.4);
    return (lift: -8 * w, lean: (-6 + 12 * w) * math.pi / 180);
  }

  /// An eased back-and-forth: 0 to 1 over each even pass, 1 to 0 over each
  /// odd one.
  static double _alternate(double passes) {
    final p = passes % 2;
    return Curves.easeInOut.transform(p < 1 ? p : 2 - p);
  }
}

/// The scene's text, drawn at the design's size whatever the text scale:
/// it is scenery, not text to read.
class _MapLabels {
  new({required this.base, required this.ink, required this.onPrimary})
    : code = _label('404', base, 36, ink, letterSpacing: -1),
      uncharted = _label('UNCHARTED', base, 8, ink, letterSpacing: 2),
      question = _label('?', base, 17, onPrimary),
      north = _label('N', base, 11, ink),
      south = _label('S', base, 11, ink),
      west = _label('W', base, 11, ink),
      east = _label('E', base, 11, ink);

  final TextStyle base;
  final Color ink;
  final Color onPrimary;
  final TextPainter code;
  final TextPainter uncharted;
  final TextPainter question;
  final TextPainter north;
  final TextPainter south;
  final TextPainter west;
  final TextPainter east;

  bool matches(_MapLabels? other) =>
      other != null &&
      other.base == base &&
      other.ink == ink &&
      other.onPrimary == onPrimary;

  void dispose() {
    for (final painter in [code, uncharted, question, north, south, west]) {
      painter.dispose();
    }
    east.dispose();
  }

  static TextPainter _label(
    String text,
    TextStyle base,
    double size,
    Color colour, {
    double letterSpacing = 0,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: base.copyWith(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: letterSpacing,
          height: 1,
          color: colour,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  /// Paints [label] centred on [anchor]'s x, with its baseline on its y, as
  /// the design's text sits.
  static void paintAt(Canvas canvas, TextPainter label, Offset anchor) {
    label.paint(
      canvas,
      Offset(
        anchor.dx - label.width / 2,
        anchor.dy - label.computeDistanceToActualBaseline(.alphabetic),
      ),
    );
  }
}

/// Paints one layer in stage units: the canvas is moved and scaled so the
/// stage fits the composition box.
abstract class _StagePainter extends CustomPainter {
  new({required this.fit, required this.colours, this.clock})
    : super(repaint: clock);

  final _StageFit fit;
  final _MapColours colours;
  final ValueNotifier<double?>? clock;

  MapScenePalette get map => colours.map;

  void paintStage(Canvas canvas, _Ambient ambient);

  @override
  void paint(Canvas canvas, Size size) {
    if (fit.scale <= 0) {
      return;
    }

    canvas
      ..save()
      ..translate(fit.origin.dx, fit.origin.dy)
      ..scale(fit.scale);
    paintStage(canvas, _Ambient(clock?.value));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StagePainter oldDelegate) =>
      oldDelegate.runtimeType != runtimeType ||
      oldDelegate.fit != fit ||
      oldDelegate.colours != colours ||
      !identical(oldDelegate.clock, clock);

  /// A stroke for lines and outlines.
  static Paint stroke(Color colour, double width) => Paint()
    ..color = colour
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  /// Turns the canvas by [degrees] about [centre], as SVG's rotate does.
  static void rotateAbout(Canvas canvas, double degrees, Offset centre) {
    canvas
      ..translate(centre.dx, centre.dy)
      ..rotate(degrees * math.pi / 180)
      ..translate(-centre.dx, -centre.dy);
  }
}

/// Map rings, like contour lines, in the sky.
class _RingsPainter extends _StagePainter {
  new({required super.fit, required super.colours});

  static const Offset _centre = Offset(300, 150);
  static const List<Size> _radii = [
    Size(60, 40),
    Size(110, 74),
    Size(165, 112),
    Size(225, 152),
    Size(290, 196),
  ];

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    final paint = _StagePainter.stroke(map.far, 1.5);
    for (final radius in _radii) {
      canvas.drawOval(
        Rect.fromCenter(
          center: _centre,
          width: 2 * radius.width,
          height: 2 * radius.height,
        ),
        paint,
      );
    }
  }
}

/// The far map card, with contour lines, two folds, and the "404" title box.
class _FarMapPainter extends _StagePainter {
  new({
    required super.fit,
    required super.colours,
    required this.labels,
    required super.clock,
  });

  final _MapLabels labels;

  static final List<Path> _contours = [
    Path()
      ..moveTo(44, 150)
      ..cubicTo(90, 130, 130, 168, 180, 148)
      ..cubicTo(230, 128, 250, 140, 262, 152),
    Path()
      ..moveTo(44, 186)
      ..cubicTo(92, 168, 140, 204, 190, 184)
      ..cubicTo(240, 164, 248, 178, 262, 188),
    Path()
      ..moveTo(44, 224)
      ..cubicTo(96, 206, 146, 240, 196, 222)
      ..cubicTo(246, 204, 250, 216, 262, 226),
  ];

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    canvas
      ..save()
      ..translate(0, ambient.float(9));
    _StagePainter.rotateAbout(canvas, -9, const Offset(150, 200));

    canvas.drawRRect(
      RRect.fromLTRBR(24, 100, 274, 270, const Radius.circular(6)),
      Paint()..color = map.far,
    );
    final contour = _StagePainter.stroke(map.mid, 1.5);
    for (final path in _contours) {
      canvas.drawPath(path, contour);
    }
    final fold = Paint()
      ..color = colours.sky
      ..strokeWidth = 2;
    canvas
      ..drawLine(const Offset(107, 100), const Offset(107, 270), fold)
      ..drawLine(const Offset(190, 100), const Offset(190, 270), fold);

    final titleBox = RRect.fromLTRBR(
      40,
      110,
      152,
      168,
      const Radius.circular(4),
    );
    canvas
      ..drawRRect(titleBox, Paint()..color = map.cloud)
      ..drawRRect(titleBox, _StagePainter.stroke(map.mid, 1.5));
    _MapLabels.paintAt(canvas, labels.code, const Offset(96, 146));
    _MapLabels.paintAt(canvas, labels.uncharted, const Offset(96, 160));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FarMapPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      !identical(oldDelegate.labels, labels);
}

/// The near map card, with folds, contour rings, and the dotted route
/// marching toward the pin.
class _NearMapPainter extends _StagePainter {
  new({required super.fit, required super.colours, required super.clock});

  static final Path _contour = Path()
    ..moveTo(154, 372)
    ..cubicTo(190, 352, 230, 384, 272, 366)
    ..cubicTo(314, 348, 350, 356, 362, 368);

  static final PathMetric _route =
      (Path()
            ..moveTo(168, 392)
            ..cubicTo(200, 380, 214, 346, 246, 340)
            ..cubicTo(286, 332, 300, 296, 330, 272)
            ..cubicTo(350, 256, 368, 250, 392, 238))
          .computeMetrics()
          .single;

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    canvas
      ..save()
      ..translate(0, ambient.float(7, reversed: true));
    _StagePainter.rotateAbout(canvas, 7, const Offset(255, 320));

    canvas.drawRRect(
      RRect.fromLTRBR(138, 228, 374, 412, const Radius.circular(6)),
      Paint()..color = map.cloud,
    );
    final fold = Paint()
      ..color = map.foam
      ..strokeWidth = 2;
    canvas
      ..drawLine(const Offset(217, 228), const Offset(217, 412), fold)
      ..drawLine(const Offset(296, 228), const Offset(296, 412), fold);
    final contour = _StagePainter.stroke(map.mid, 1.5);
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(300, 300), width: 68, height: 44),
        contour,
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(300, 300), width: 116, height: 80),
        contour,
      )
      ..drawPath(_contour, contour);

    final dot = Paint()..color = colours.primary;
    for (
      var distance = ambient.march;
      distance <= _route.length;
      distance += _Ambient.dotSpacing
    ) {
      final position = _route.getTangentForOffset(distance)?.position;
      if (position != null) {
        canvas.drawCircle(position, 1.5, dot);
      }
    }

    canvas.restore();
  }
}

/// The small map card, with wave lines.
class _SmallMapPainter extends _StagePainter {
  new({required super.fit, required super.colours, required super.clock});

  /// Each wave line: where it starts and how many 20-unit waves it has.
  static const List<(Offset, int)> _waves = [
    (Offset(34, 364), 4),
    (Offset(62, 392), 4),
    (Offset(38, 420), 3),
  ];

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    canvas
      ..save()
      ..translate(0, ambient.float(5.5, delay: 2));
    _StagePainter.rotateAbout(canvas, -5, const Offset(110, 390));

    canvas.drawRRect(
      RRect.fromLTRBR(16, 330, 196, 458, const Radius.circular(6)),
      Paint()..color = map.foam,
    );
    final line = _StagePainter.stroke(map.back, 1.8);
    for (final (start, count) in _waves) {
      final path = Path()..moveTo(start.dx, start.dy);
      for (var i = 0; i < count; i++) {
        final x = start.dx + 20 * i;
        path.quadraticBezierTo(
          x + 10,
          start.dy + (i.isEven ? -7 : 7),
          x + 20,
          start.dy,
        );
      }
      canvas.drawPath(path, line);
    }

    canvas.restore();
  }
}

/// The pin with a "?", bobbing on its tip, and its shadow on the map.
class _PinPainter extends _StagePainter {
  new({
    required super.fit,
    required super.colours,
    required this.labels,
    required super.clock,
  });

  final _MapLabels labels;

  static const Offset _tip = Offset(346, 214);

  /// The pin's outline with its tip at the origin.
  static final Path _pin = Path()
    ..moveTo(0, 0)
    ..cubicTo(-4, -10, -16, -20, -16, -32)
    ..arcToPoint(
      const Offset(16, -32),
      radius: const Radius.circular(16),
      largeArc: true,
    )
    ..cubicTo(16, -20, 4, -10, 0, 0)
    ..close();

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    final bob = ambient.bob;
    canvas
      ..save()
      ..translate(_tip.dx, _tip.dy + bob.lift)
      ..rotate(bob.lean)
      ..drawPath(_pin, Paint()..color = colours.primary);
    _MapLabels.paintAt(canvas, labels.question, const Offset(0, -26));
    canvas
      ..restore()
      ..drawOval(
        Rect.fromCenter(center: const Offset(346, 222), width: 18, height: 5),
        Paint()..color = map.pinShadow,
      );
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      !identical(oldDelegate.labels, labels);
}

/// The compass face: rim, ticks and the four letters. The needle is drawn
/// on its own layer, so it can turn to the heading.
class _CompassPainter extends _StagePainter {
  new({required super.fit, required super.colours, required this.labels});

  final _MapLabels labels;

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    final rim = _StagePainter.stroke(map.close, 2);
    final minor = _StagePainter.stroke(map.mid, 1.5);
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(200, 510), width: 112, height: 16),
        Paint()..color = map.compassShadow,
      )
      ..drawCircle(_compassCentre, 62, Paint()..color = map.cloud)
      ..drawCircle(_compassCentre, 62, _StagePainter.stroke(map.close, 3))
      ..drawCircle(_compassCentre, 48, _StagePainter.stroke(map.far, 2))
      ..drawLine(const Offset(195, 382), const Offset(195, 390), rim)
      ..drawLine(const Offset(195, 490), const Offset(195, 498), rim)
      ..drawLine(const Offset(137, 440), const Offset(145, 440), rim)
      ..drawLine(const Offset(245, 440), const Offset(253, 440), rim)
      ..drawLine(const Offset(154, 399), const Offset(159, 404), minor)
      ..drawLine(const Offset(236, 399), const Offset(231, 404), minor)
      ..drawLine(const Offset(154, 481), const Offset(159, 476), minor)
      ..drawLine(const Offset(236, 481), const Offset(231, 476), minor);
    _MapLabels.paintAt(canvas, labels.north, const Offset(195, 406));
    _MapLabels.paintAt(canvas, labels.south, const Offset(195, 483));
    _MapLabels.paintAt(canvas, labels.west, const Offset(160, 444));
    _MapLabels.paintAt(canvas, labels.east, const Offset(230, 444));
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      !identical(oldDelegate.labels, labels);
}

/// The needle, pointing up, and the hub over it. The layer above turns it to
/// the heading.
class _NeedlePainter extends _StagePainter {
  new({required super.fit, required super.colours});

  static final Path _north = Path()
    ..moveTo(195, 396)
    ..lineTo(203, 440)
    ..lineTo(187, 440)
    ..close();

  static final Path _south = Path()
    ..moveTo(195, 484)
    ..lineTo(203, 440)
    ..lineTo(187, 440)
    ..close();

  @override
  void paintStage(Canvas canvas, _Ambient ambient) {
    canvas
      ..drawPath(_north, Paint()..color = colours.primary)
      ..drawPath(_south, Paint()..color = map.mid)
      ..drawCircle(_compassCentre, 4.5, Paint()..color = map.ink);
  }
}
