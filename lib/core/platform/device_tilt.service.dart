import 'dart:async';
import 'dart:math' as math;

import 'package:injectable/injectable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Reports how far the device is tilted away from where it rested, in the
/// screen's axes.
///
/// Each call to [watchTilt] starts a fresh measurement: the resting angle is
/// the angle when the stream is listened to, and it drifts slowly toward the
/// current angle so a new way of holding the device becomes the new rest.
/// Cancelling the subscription stops the sensors.
@lazySingleton
class DeviceTiltService {
  new()
    : this.withSources(
        gyroscope: () => gyroscopeEventStream(samplingPeriod: _samplingPeriod),
        accelerometer: () =>
            accelerometerEventStream(samplingPeriod: _samplingPeriod),
        isLandscape: _isImplicitViewLandscape,
      );

  /// Reads the given sensor streams and screen orientation instead of the
  /// device's own.
  @visibleForTesting
  new withSources({
    required this._gyroscope,
    required this._accelerometer,
    required this._isLandscape,
  });

  static const Duration _samplingPeriod = SensorInterval.gameInterval;

  final Stream<GyroscopeEvent> Function() _gyroscope;
  final Stream<AccelerometerEvent> Function() _accelerometer;
  final bool Function() _isLandscape;

  /// Tilt from -1 to 1 on each axis: `dx > 0` when the screen's right edge
  /// dips, `dy > 0` when its bottom edge dips.
  ///
  /// Reads the gyroscope, or the accelerometer when the device has none. The
  /// accelerometer also tells which way a landscape screen is turned. The
  /// stream stays silent when neither sensor is available.
  Stream<Offset> watchTilt() {
    late final StreamController<Offset> controller;
    StreamSubscription<GyroscopeEvent>? gyroscope;
    StreamSubscription<AccelerometerEvent>? accelerometer;
    final filter = _TiltFilter();
    var angle = Offset.zero;
    var hasGyroscope = true;
    var isTopEdgeLeft = true;
    DateTime? lastGyroscopeAt;

    void report(Offset deviceAngle, DateTime at) {
      final tilt = filter.add(angle: deviceAngle, at: at);
      controller.add(_toScreen(tilt, isTopEdgeLeft: isTopEdgeLeft));
    }

    void onGyroscope(GyroscopeEvent event) {
      final previous = lastGyroscopeAt;
      lastGyroscopeAt = event.timestamp;
      if (previous != null) {
        final seconds =
            event.timestamp.difference(previous).inMicroseconds /
            Duration.microsecondsPerSecond;
        angle += Offset(event.y, event.x) * seconds;
      }
      report(angle, event.timestamp);
    }

    void onAccelerometer(AccelerometerEvent event) {
      isTopEdgeLeft = event.x >= 0;
      if (hasGyroscope) {
        return;
      }

      final pitchPlane = math.sqrt(event.y * event.y + event.z * event.z);
      report(
        Offset(math.atan2(-event.x, pitchPlane), math.atan2(event.y, event.z)),
        event.timestamp,
      );
    }

    // Synchronous: each reading is forwarded from inside a sensor event.
    controller = StreamController<Offset>(
      sync: true,
      onListen: () {
        gyroscope = _gyroscope().listen(
          onGyroscope,
          onError: (Object _) {
            hasGyroscope = false;
            unawaited(gyroscope?.cancel());
          },
        );
        accelerometer = _accelerometer().listen(
          onAccelerometer,
          onError: (Object _) => unawaited(accelerometer?.cancel()),
        );
      },
      onPause: () {
        gyroscope?.pause();
        accelerometer?.pause();
      },
      onResume: () {
        gyroscope?.resume();
        accelerometer?.resume();
      },
      onCancel: () async {
        await Future.wait([
          ?gyroscope?.cancel(),
          ?accelerometer?.cancel(),
        ]);
        await controller.close();
      },
    );

    return controller.stream;
  }

  /// The sensors use the device's axes. A landscape screen turns them a
  /// quarter turn one way or the other, and gravity says which.
  Offset _toScreen(Offset tilt, {required bool isTopEdgeLeft}) {
    if (!_isLandscape()) {
      return tilt;
    }

    return isTopEdgeLeft
        ? Offset(tilt.dy, -tilt.dx)
        : Offset(-tilt.dy, tilt.dx);
  }

  static bool _isImplicitViewLandscape() {
    final size =
        WidgetsBinding.instance.platformDispatcher.implicitView?.physicalSize;

    return size != null && size.width > size.height;
  }
}

/// Turns raw device angles into a smoothed tilt from -1 to 1.
///
/// The first angle is the resting angle. Later angles are measured from a
/// resting angle that drifts toward them, and the result passes through a
/// low-pass filter so layers glide instead of jittering.
class _TiltFilter {
  /// The angle in radians, away from rest, that reads as a full tilt of 1.
  static const double _fullTilt = 0.35;
  static const Duration _restTimeConstant = Duration(seconds: 4);
  static const Duration _smoothingTimeConstant = Duration(milliseconds: 150);

  Offset? _rest;
  Offset _smoothed = Offset.zero;
  DateTime? _lastAt;

  Offset add({required Offset angle, required DateTime at}) {
    final rest = _rest;
    final lastAt = _lastAt;
    _lastAt = at;
    if (rest == null || lastAt == null) {
      _rest = angle;
      return _smoothed;
    }

    final seconds =
        at.difference(lastAt).inMicroseconds / Duration.microsecondsPerSecond;
    final nextRest = rest + (angle - rest) * _blend(seconds, _restTimeConstant);
    _rest = nextRest;

    final target = (angle - nextRest) / _fullTilt;
    final clamped = Offset(
      target.dx.clamp(-1.0, 1.0),
      target.dy.clamp(-1.0, 1.0),
    );

    return _smoothed +=
        (clamped - _smoothed) * _blend(seconds, _smoothingTimeConstant);
  }

  double _blend(double seconds, Duration timeConstant) {
    if (seconds <= 0) {
      return 0;
    }

    final tau = timeConstant.inMicroseconds / Duration.microsecondsPerSecond;

    return 1 - math.exp(-seconds / tau);
  }
}
