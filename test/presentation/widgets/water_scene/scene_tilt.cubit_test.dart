import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/widgets/water_scene/scene_tilt.cubit.dart';

import '../../../support/fake_device_tilt_service.dart';

void main() {
  late FakeDeviceTiltService tilt;

  setUp(() => tilt = FakeDeviceTiltService());

  void allowMotion(SceneTiltCubit cubit) => cubit.sceneConditionsChanged(
    isAppResumed: true,
    isOnScreen: true,
    reduceMotion: false,
  );

  group('SceneTiltCubit', () {
    test('starts at rest with the sensors off', () {
      final cubit = SceneTiltCubit(tilt);
      addTearDown(cubit.close);

      expect(cubit.state, Offset.zero);
      expect(tilt.isListening, isFalse);
    });

    blocTest<SceneTiltCubit, Offset>(
      'follows the device tilt while the scene may move',
      build: () => SceneTiltCubit(tilt),
      act: (cubit) {
        allowMotion(cubit);
        expect(tilt.isListening, isTrue);
        tilt.tilt(const Offset(0.5, -0.25));
      },
      expect: () => const [Offset(0.5, -0.25)],
    );

    for (final (reason, resumed, onScreen, reduceMotion) in [
      ('the app goes to the background', false, true, false),
      ('the scene leaves the screen', true, false, false),
      ('Reduce Motion is on', true, true, true),
    ]) {
      blocTest<SceneTiltCubit, Offset>(
        'stops the sensors and rests when $reason',
        build: () => SceneTiltCubit(tilt),
        act: (cubit) {
          allowMotion(cubit);
          tilt.tilt(const Offset(1, 0));
          cubit.sceneConditionsChanged(
            isAppResumed: resumed,
            isOnScreen: onScreen,
            reduceMotion: reduceMotion,
          );
        },
        expect: () => const [Offset(1, 0), Offset.zero],
        verify: (_) => expect(tilt.isListening, isFalse),
      );
    }

    blocTest<SceneTiltCubit, Offset>(
      'listens again when the scene may move again',
      build: () => SceneTiltCubit(tilt),
      act: (cubit) {
        allowMotion(cubit);
        cubit.sceneConditionsChanged(
          isAppResumed: false,
          isOnScreen: true,
          reduceMotion: false,
        );
        allowMotion(cubit);
        expect(tilt.isListening, isTrue);
      },
    );

    test('closing stops the sensors', () async {
      final cubit = SceneTiltCubit(tilt);
      allowMotion(cubit);

      await cubit.close();

      expect(tilt.isListening, isFalse);
    });
  });
}
