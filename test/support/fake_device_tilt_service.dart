import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/core/platform/device_tilt.service.dart';

/// [DeviceTiltService] whose tilt the test sets directly with [tilt].
class FakeDeviceTiltService implements DeviceTiltService {
  final _tilt = StreamController<Offset>.broadcast(sync: true);

  /// Whether the scene is listening, which means the sensors would be on.
  bool get isListening => _tilt.hasListener;

  @override
  Stream<Offset> watchTilt() => _tilt.stream;

  void tilt(Offset value) => _tilt.add(value);
}
