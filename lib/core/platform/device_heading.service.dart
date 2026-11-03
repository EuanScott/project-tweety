import 'dart:async';
import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Reports which way the top of the screen points, in degrees clockwise from
/// magnetic north.
///
/// It reads the magnetometer and the accelerometer, which need no permission
/// on iOS or Android. True north would need the person's location, so it is
/// not used. Cancelling the subscription stops the sensors.
@lazySingleton
class DeviceHeadingService {
  new()
    : this.withSources(
        magnetometer: () =>
            magnetometerEventStream(samplingPeriod: _samplingPeriod),
        accelerometer: () =>
            accelerometerEventStream(samplingPeriod: _samplingPeriod),
        isLandscape: _isImplicitViewLandscape,
      );

  /// Reads the given sensor streams and screen orientation instead of the
  /// device's own.
  @visibleForTesting
  new withSources({
    required this._magnetometer,
    required this._accelerometer,
    required this._isLandscape,
  });

  static const Duration _samplingPeriod = SensorInterval.gameInterval;

  final Stream<MagnetometerEvent> Function() _magnetometer;
  final Stream<AccelerometerEvent> Function() _accelerometer;
  final bool Function() _isLandscape;

  /// The heading of the top of the screen, in degrees clockwise from
  /// magnetic north, smoothed.
  ///
  /// The heading is continuous, not wrapped to one turn: turning past south
  /// from 179° reads 181°, not -179°. A needle turned by it never spins the
  /// long way round.
  ///
  /// The stream stays silent when the device has no magnetometer.
  Stream<double> watchHeading() {
    late final StreamController<double> controller;
    StreamSubscription<MagnetometerEvent>? magnetometer;
    StreamSubscription<AccelerometerEvent>? accelerometer;
    final filter = _HeadingFilter();
    AccelerometerEvent? gravity;
    bool? isTopEdgeLeft;

    void onMagnetometer(MagnetometerEvent field) {
      final down = gravity;
      if (down == null) {
        return;
      }

      final heading = _deviceHeading(down, field);
      if (heading != null) {
        controller.add(
          filter.add(
            heading: _toScreen(heading, isTopEdgeLeft: isTopEdgeLeft ?? true),
            at: field.timestamp,
          ),
        );
      }
    }

    // A heading needs both sensors, so losing either stops both.
    void stopSensors(Object _) {
      unawaited(magnetometer?.cancel());
      unawaited(accelerometer?.cancel());
    }

    // Synchronous: each reading is forwarded from inside a sensor event.
    controller = StreamController<double>(
      sync: true,
      onListen: () {
        accelerometer = _accelerometer().listen((event) {
          gravity = event;
          isTopEdgeLeft = _isTopEdgeLeft(event, was: isTopEdgeLeft);
        }, onError: stopSensors);
        magnetometer = _magnetometer().listen(
          onMagnetometer,
          onError: stopSensors,
        );
      },
      onPause: () {
        magnetometer?.pause();
        accelerometer?.pause();
      },
      onResume: () {
        magnetometer?.resume();
        accelerometer?.resume();
      },
      onCancel: () async {
        await Future.wait([?magnetometer?.cancel(), ?accelerometer?.cancel()]);
        await controller.close();
      },
    );

    return controller.stream;
  }

  /// The heading of the device's top edge, tilt-compensated, or null when
  /// the readings give no direction.
  ///
  /// East is the field crossed with gravity, and north is gravity crossed
  /// with east, both in the device's axes. The heading is the angle of the
  /// top edge (the y axis) between them.
  static double? _deviceHeading(AccelerometerEvent a, MagnetometerEvent e) {
    final eastX = e.y * a.z - e.z * a.y;
    final eastY = e.z * a.x - e.x * a.z;
    final eastZ = e.x * a.y - e.y * a.x;
    final eastLength = math.sqrt(eastX * eastX + eastY * eastY + eastZ * eastZ);
    final gravityLength = math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
    if (eastLength < 0.1 || gravityLength < 0.1) {
      return null;
    }

    final east = (
      x: eastX / eastLength,
      y: eastY / eastLength,
      z: eastZ / eastLength,
    );
    final up = (
      x: a.x / gravityLength,
      y: a.y / gravityLength,
      z: a.z / gravityLength,
    );
    final northY = up.z * east.x - up.x * east.z;

    return math.atan2(east.y, northY) * 180 / math.pi;
  }

  /// Gravity along the device's width, in m/s², that clearly tips a
  /// landscape device to one side: about 12°.
  static const double _sideThreshold = 2;

  /// Which way a landscape device is turned: true when its top edge is to the
  /// left, so its right edge is up and gravity reads along +x, as in the tilt
  /// service. The side changes only when the device clearly tips the other
  /// way, so a device lying almost flat does not flip the needle on noise.
  static bool _isTopEdgeLeft(AccelerometerEvent gravity, {required bool? was}) {
    if (was == null) {
      return gravity.x >= 0;
    }
    if (gravity.x > _sideThreshold) {
      return true;
    }
    if (gravity.x < -_sideThreshold) {
      return false;
    }

    return was;
  }

  /// A landscape screen's top is the device's right or left edge, a quarter
  /// turn from its top edge.
  double _toScreen(double heading, {required bool isTopEdgeLeft}) {
    if (!_isLandscape()) {
      return heading;
    }

    return isTopEdgeLeft ? heading + 90 : heading - 90;
  }

  static bool _isImplicitViewLandscape() {
    final size =
        WidgetsBinding.instance.platformDispatcher.implicitView?.physicalSize;

    return size != null && size.width > size.height;
  }
}

/// Smooths raw headings with a low-pass filter, so a needle glides instead of
/// jittering. It moves by the shortest turn and never wraps, so the heading
/// stays continuous across south and north.
class _HeadingFilter {
  static const Duration _smoothingTimeConstant = Duration(milliseconds: 200);

  double? _smoothed;
  DateTime? _lastAt;

  double add({required double heading, required DateTime at}) {
    final smoothed = _smoothed;
    final lastAt = _lastAt;
    _lastAt = at;
    if (smoothed == null || lastAt == null) {
      return _smoothed = heading;
    }

    final seconds =
        at.difference(lastAt).inMicroseconds / Duration.microsecondsPerSecond;

    // The shortest turn from the smoothed heading to the new one, from -180°
    // to 180°.
    final turn = (heading - smoothed + 180) % 360 - 180;

    return _smoothed = smoothed + turn * _blend(seconds);
  }

  double _blend(double seconds) {
    if (seconds <= 0) {
      return 0;
    }

    final tau =
        _smoothingTimeConstant.inMicroseconds / Duration.microsecondsPerSecond;

    return 1 - math.exp(-seconds / tau);
  }
}
