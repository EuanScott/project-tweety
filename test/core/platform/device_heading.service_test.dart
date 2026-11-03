import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/core/platform/device_heading.service.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  late StreamController<MagnetometerEvent> magnetometer;
  late StreamController<AccelerometerEvent> accelerometer;
  late bool isLandscape;
  late DeviceHeadingService service;
  late List<double> headings;
  StreamSubscription<double>? subscription;

  final start = DateTime(2026);
  DateTime at(int milliseconds) =>
      start.add(Duration(milliseconds: milliseconds));

  setUp(() {
    magnetometer = StreamController<MagnetometerEvent>(sync: true);
    accelerometer = StreamController<AccelerometerEvent>(sync: true);
    isLandscape = false;
    headings = [];
    service = DeviceHeadingService.withSources(
      magnetometer: () => magnetometer.stream,
      accelerometer: () => accelerometer.stream,
      isLandscape: () => isLandscape,
    );
  });

  tearDown(() async {
    await subscription?.cancel();
    subscription = null;
    await magnetometer.close();
    await accelerometer.close();
  });

  void listen() {
    subscription = service.watchHeading().listen(headings.add);
  }

  /// How far the device is rolled about its long axis, in radians; positive
  /// lifts the right edge.
  var roll = 0.0;

  /// Gravity for a face-up device rolled by [rollBy] radians.
  void flat(int milliseconds, {double rollBy = 0}) {
    roll = rollBy;
    accelerometer.add(
      AccelerometerEvent(
        9.8 * math.sin(roll),
        0,
        9.8 * math.cos(roll),
        at(milliseconds),
      ),
    );
  }

  /// The magnetic field the device reads, as last rolled by [flat], when its
  /// top edge points [degrees] clockwise from magnetic north. The field dips
  /// into the ground, as it does in southern Africa and in Europe.
  void facing(double degrees, int milliseconds) {
    final radians = degrees * math.pi / 180;
    // Up, and the level direction across the device, in the device's axes.
    final up = (x: math.sin(roll), z: math.cos(roll));
    final across = (x: math.cos(roll), z: -math.sin(roll));
    final northAcross = -20 * math.sin(radians);
    magnetometer.add(
      MagnetometerEvent(
        northAcross * across.x - 40 * up.x,
        20 * math.cos(radians),
        northAcross * across.z - 40 * up.z,
        at(milliseconds),
      ),
    );
  }

  group('DeviceHeadingService', () {
    test('reads 0° with the top edge to magnetic north', () {
      listen();
      flat(0);
      facing(0, 0);

      expect(headings.single, closeTo(0, 0.01));
    });

    test('turns clockwise: east reads 90°, north-west reads -45°', () {
      listen();
      flat(0);
      facing(90, 0);
      flat(5000);
      facing(-45, 5000);

      expect(headings.first, closeTo(90, 0.01));
      expect(headings.last, closeTo(-45, 0.01));
    });

    test('glides toward a new heading instead of jumping', () {
      listen();
      flat(0);
      facing(0, 0);
      for (var ms = 20; ms <= 2000; ms += 20) {
        flat(ms);
        facing(60, ms);
      }

      expect(headings[1], inExclusiveRange(0, 30));
      expect(headings.last, closeTo(60, 0.5));
    });

    test('takes the short way across south: 170° then 190° reads 190°', () {
      listen();
      flat(0);
      facing(170, 0);
      for (var ms = 20; ms <= 2000; ms += 20) {
        flat(ms);
        facing(190, ms);
      }

      expect(headings, everyElement(inInclusiveRange(170, 190.01)));
      expect(headings.last, closeTo(190, 0.5));
    });

    test('corrects for a landscape screen, whichever way it is turned', () {
      isLandscape = true;
      listen();
      // Top edge to the left: the screen's top is the device's right edge.
      flat(0, rollBy: 0.3);
      facing(0, 0);
      // Top edge to the right: the screen's top is the device's left edge.
      flat(5000, rollBy: -0.3);
      facing(0, 5000);

      expect(headings.first, closeTo(90, 1));
      expect(headings.last, closeTo(-90, 1));
    });

    test(
      'stays silent, and stops the accelerometer, without a magnetometer',
      () {
        listen();
        magnetometer.addError(StateError('no magnetometer'));
        flat(0);

        expect(headings, isEmpty);
        expect(accelerometer.hasListener, isFalse);
      },
    );

    test('cancelling stops both sensors', () async {
      listen();

      await subscription?.cancel();
      subscription = null;

      expect(magnetometer.hasListener, isFalse);
      expect(accelerometer.hasListener, isFalse);
    });

    test('in landscape, keeps its side while the device lies almost flat', () {
      isLandscape = true;
      listen();
      flat(0, rollBy: 0.3);
      facing(0, 0);
      // Nearly flat, tipped a hair the other way: sensor noise, not a turn.
      flat(5000, rollBy: -0.02);
      facing(0, 5000);
      // Clearly tipped the other way.
      flat(10000, rollBy: -0.4);
      facing(0, 10000);

      expect(headings[0], closeTo(90, 1));
      expect(headings[1], closeTo(90, 1));
      expect(headings[2], closeTo(-90, 1));
    });

    test('takes the short way across north: 359° then 1°', () {
      listen();
      flat(0);
      facing(359, 0);
      flat(20);
      facing(1, 20);
      flat(5000);
      facing(1, 5000);

      expect(headings.first, closeTo(-1, 0.01));
      expect(headings[1], inExclusiveRange(-1, 1));
      expect(headings.last, closeTo(1, 0.01));

      headings.clear();
      flat(5020);
      facing(359, 5020);
      flat(10000);
      facing(359, 10000);
      flat(15000);
      facing(1, 15000);

      expect(headings, everyElement(inInclusiveRange(-1.01, 1.01)));
    });
  });
}
