import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/platform/device_heading.service.dart';

/// The compass needle's heading, in degrees clockwise from magnetic north, or
/// null when there is none and the needle points up.
///
/// The scene reports where it stands; this decides when the sensors run.
/// They run only while the app is in the foreground, the page is on screen,
/// and Reduce Motion is off. Otherwise there is no heading.
@injectable
class CompassHeadingCubit extends Cubit<double?> {
  new(this._deviceHeading) : super(null);

  final DeviceHeadingService _deviceHeading;
  StreamSubscription<double>? _subscription;

  void sceneConditionsChanged({
    required bool isAppResumed,
    required bool isOnScreen,
    required bool reduceMotion,
  }) {
    final shouldListen = isAppResumed && isOnScreen && !reduceMotion;
    final subscription = _subscription;

    if (shouldListen && subscription == null) {
      _subscription = _deviceHeading.watchHeading().listen(emit);
    } else if (!shouldListen && subscription != null) {
      unawaited(subscription.cancel());
      _subscription = null;
      emit(null);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
