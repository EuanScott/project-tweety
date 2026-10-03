import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/platform/device_tilt.service.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  late StreamController<GyroscopeEvent> gyroscope;
  late StreamController<AccelerometerEvent> accelerometer;
  late bool isLandscape;
  late DeviceTiltService service;
  late List<Offset> readings;
  StreamSubscription<Offset>? subscription;

  final start = DateTime(2026);
  DateTime at(int milliseconds) =>
      start.add(Duration(milliseconds: milliseconds));

  setUp(() {
    gyroscope = StreamController<GyroscopeEvent>(sync: true);
    accelerometer = StreamController<AccelerometerEvent>(sync: true);
    isLandscape = false;
    readings = [];
    service = DeviceTiltService.withSources(
      gyroscope: () => gyroscope.stream,
      accelerometer: () => accelerometer.stream,
      isLandscape: () => isLandscape,
    );
  });

  tearDown(() async {
    await subscription?.cancel();
    subscription = null;
    await gyroscope.close();
    await accelerometer.close();
  });

  void listen() {
    subscription = service.watchTilt().listen(readings.add);
  }

  /// Gravity for a device turned [angle] radians so its right edge dips,
  /// lying otherwise flat.
  AccelerometerEvent gravity(double angle, int milliseconds) =>
      AccelerometerEvent(
        -9.8 * math.sin(angle),
        0,
        9.8 * math.cos(angle),
        at(milliseconds),
      );

  /// Holds [angle] on the accelerometer from [from] to [to] milliseconds.
  void hold(double angle, {required int from, required int to}) {
    for (var ms = from; ms <= to; ms += 20) {
      accelerometer.add(gravity(angle, ms));
    }
  }

  group('DeviceTiltService on the accelerometer', () {
    setUp(() {
      listen();
      gyroscope.addError(StateError('no gyroscope'));
    });

    test('reads zero at the resting angle', () {
      hold(0.4, from: 0, to: 40);

      expect(readings, everyElement(Offset.zero));
    });

    test('glides toward a held tilt instead of jumping', () {
      hold(0, from: 0, to: 0);
      hold(0.1, from: 20, to: 1000);

      expect(readings[1].dx, inExclusiveRange(0, 0.1));
      expect(readings.last.dx, closeTo(0.22, 0.02));
      expect(readings.last.dy, closeTo(0, 0.001));
    });

    test('clamps to the range -1 to 1', () {
      hold(0, from: 0, to: 0);
      hold(1.2, from: 20, to: 600);

      expect(readings.last.dx, closeTo(1, 0.02));
    });

    test('lets the resting angle drift toward the current angle', () {
      hold(0, from: 0, to: 0);
      hold(0.1, from: 20, to: 30000);

      expect(readings.last.dx, closeTo(0, 0.01));
    });
  });

  group('DeviceTiltService on the gyroscope', () {
    /// Turns the device about its own y axis at [rate] radians per second.
    void rotate(double rate, {required int from, required int to}) {
      for (var ms = from; ms <= to; ms += 20) {
        gyroscope.add(GyroscopeEvent(0, rate, 0, at(ms)));
      }
    }

    test('integrates rotation into tilt', () {
      listen();
      rotate(0.5, from: 0, to: 200);
      rotate(0, from: 220, to: 600);

      expect(readings.last.dx, greaterThan(0.2));
      expect(readings.last.dy, closeTo(0, 0.001));
    });

    test('maps tilt into screen axes in both landscape directions', () {
      listen();
      isLandscape = true;
      accelerometer.add(AccelerometerEvent(9.8, 0, 0, at(0)));
      rotate(0.5, from: 0, to: 200);
      rotate(0, from: 220, to: 600);
      final topEdgeLeft = readings.last;

      accelerometer.add(AccelerometerEvent(-9.8, 0, 0, at(620)));
      rotate(0, from: 620, to: 640);
      final topEdgeRight = readings.last;

      expect(topEdgeLeft.dx, closeTo(0, 0.001));
      expect(topEdgeLeft.dy, lessThan(-0.2));
      expect(topEdgeRight.dy, closeTo(-topEdgeLeft.dy, 0.05));
    });
  });

  test('cancelling stops both sensors', () async {
    listen();
    expect(gyroscope.hasListener, isTrue);
    expect(accelerometer.hasListener, isTrue);

    await subscription!.cancel();
    subscription = null;

    expect(gyroscope.hasListener, isFalse);
    expect(accelerometer.hasListener, isFalse);
  });

  test('stays silent when neither sensor is available', () {
    listen();
    gyroscope.addError(StateError('no gyroscope'));
    accelerometer.addError(StateError('no accelerometer'));

    expect(readings, isEmpty);
    expect(accelerometer.hasListener, isFalse);
  });
}
