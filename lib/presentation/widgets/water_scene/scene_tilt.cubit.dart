import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/platform/device_tilt.service.dart';

/// The water scene's tilt, from -1 to 1 on each axis.
///
/// The scene reports where it stands; this decides when the sensors run.
/// They run only while the app is in the foreground, the scene is on screen,
/// and Reduce Motion is off. Otherwise the tilt rests at zero.
@injectable
class SceneTiltCubit extends Cubit<Offset> {
  new(this._deviceTilt) : super(Offset.zero);

  final DeviceTiltService _deviceTilt;
  StreamSubscription<Offset>? _subscription;

  void sceneConditionsChanged({
    required bool isAppResumed,
    required bool isOnScreen,
    required bool reduceMotion,
  }) {
    final shouldListen = isAppResumed && isOnScreen && !reduceMotion;
    final subscription = _subscription;

    if (shouldListen && subscription == null) {
      _subscription = _deviceTilt.watchTilt().listen(emit);
    } else if (!shouldListen && subscription != null) {
      unawaited(subscription.cancel());
      _subscription = null;
      emit(Offset.zero);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
