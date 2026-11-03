import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/presentation/pages/route_error/cubit/compass_heading.cubit.dart';

import '../../../../support/fake_device_heading_service.dart';

void main() {
  late FakeDeviceHeadingService heading;

  setUp(() => heading = FakeDeviceHeadingService());

  void allowMotion(CompassHeadingCubit cubit) => cubit.sceneConditionsChanged(
    isAppResumed: true,
    isOnScreen: true,
    reduceMotion: false,
  );

  group('CompassHeadingCubit', () {
    test('starts with no heading and the sensors off', () {
      final cubit = CompassHeadingCubit(heading);
      addTearDown(cubit.close);

      expect(cubit.state, isNull);
      expect(heading.isListening, isFalse);
    });

    blocTest<CompassHeadingCubit, double?>(
      'follows the heading while the page may move',
      build: () => CompassHeadingCubit(heading),
      act: (cubit) {
        allowMotion(cubit);
        expect(heading.isListening, isTrue);
        heading.turnTo(181);
      },
      expect: () => const [181.0],
    );

    for (final (reason, resumed, onScreen, reduceMotion) in [
      ('the app goes to the background', false, true, false),
      ('the page leaves the screen', true, false, false),
      ('Reduce Motion is on', true, true, true),
    ]) {
      blocTest<CompassHeadingCubit, double?>(
        'stops the sensors and drops the heading when $reason',
        build: () => CompassHeadingCubit(heading),
        act: (cubit) {
          allowMotion(cubit);
          heading.turnTo(90);
          cubit.sceneConditionsChanged(
            isAppResumed: resumed,
            isOnScreen: onScreen,
            reduceMotion: reduceMotion,
          );
        },
        expect: () => const [90.0, null],
        verify: (_) => expect(heading.isListening, isFalse),
      );
    }

    test('closing stops the sensors', () async {
      final cubit = CompassHeadingCubit(heading);
      allowMotion(cubit);

      await cubit.close();

      expect(heading.isListening, isFalse);
    });
  });
}
