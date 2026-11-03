import 'dart:async';

import 'package:project_tweety/core/platform/device_heading.service.dart';

/// [DeviceHeadingService] whose heading the test sets directly with [turnTo].
class FakeDeviceHeadingService implements DeviceHeadingService {
  final _heading = StreamController<double>.broadcast(sync: true);

  /// Whether the compass is listening, which means the sensors would be on.
  bool get isListening => _heading.hasListener;

  @override
  Stream<double> watchHeading() => _heading.stream;

  void turnTo(double degrees) => _heading.add(degrees);
}
