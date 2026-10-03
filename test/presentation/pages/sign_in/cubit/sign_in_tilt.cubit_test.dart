import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/pages/sign_in/cubit/sign_in_tilt.cubit.dart';

import '../../../../support/fake_device_tilt_service.dart';

void main() {
  late FakeDeviceTiltService tilt;

  setUp(() => tilt = FakeDeviceTiltService());

  void allowMotion(SignInTiltCubit cubit) => cubit.sceneConditionsChanged(
    isAppResumed: true,
    isOnScreen: true,
    reduceMotion: false,
  );

  group('SignInTiltCubit', () {
    test('starts at rest with the sensors off', () {
      final cubit = SignInTiltCubit(tilt);
      addTearDown(cubit.close);

      expect(cubit.state, Offset.zero);
      expect(tilt.isListening, isFalse);
    });

    blocTest<SignInTiltCubit, Offset>(
      'follows the device tilt while the scene may move',
      build: () => SignInTiltCubit(tilt),
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
      blocTest<SignInTiltCubit, Offset>(
        'stops the sensors and rests when $reason',
        build: () => SignInTiltCubit(tilt),
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

    blocTest<SignInTiltCubit, Offset>(
      'listens again when the scene may move again',
      build: () => SignInTiltCubit(tilt),
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
      final cubit = SignInTiltCubit(tilt);
      allowMotion(cubit);

      await cubit.close();

      expect(tilt.isListening, isFalse);
    });
  });
}
