import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/core/platform/orientation_policy.service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<List<String>> appliedOrientations;
  late OrientationPolicyService service;

  setUp(() {
    appliedOrientations = [];
    service = OrientationPolicyService();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
          if (methodCall.method == 'SystemChrome.setPreferredOrientations') {
            appliedOrientations.add(
              (methodCall.arguments as List<Object?>).cast<String>(),
            );
          }

          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('OrientationPolicyService', () {
    test('locks compact surfaces to portrait up', () async {
      await service.applyFor(_mediaQuery(const Size(390, 844)));

      expect(appliedOrientations, [_names(_compact)]);
    });

    test('allows landscape on expanded surfaces', () async {
      await service.applyFor(_mediaQuery(const Size(834, 1112)));

      expect(appliedOrientations, [_names(_expanded)]);
    });

    test(
      'allows landscape on a half-opened foldable with a vertical hinge',
      () async {
        await service.applyFor(
          _mediaQuery(
            const Size(580, 800),
            displayFeatures: const [
              DisplayFeature(
                bounds: Rect.fromLTWH(328, 0, 20, 800),
                type: DisplayFeatureType.hinge,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ],
          ),
        );

        expect(appliedOrientations, [_names(_expanded)]);
      },
    );

    test('never allows portrait down', () {
      expect(_compact, isNot(contains(DeviceOrientation.portraitDown)));
      expect(_expanded, isNot(contains(DeviceOrientation.portraitDown)));
    });

    test(
      'skips the platform call when the classification is unchanged',
      () async {
        await service.applyFor(_mediaQuery(const Size(390, 844)));
        await service.applyFor(
          _mediaQuery(const Size(390, 844))
              .copyWith(viewInsets: const EdgeInsets.only(bottom: 320)),
        );

        expect(appliedOrientations, hasLength(1));
      },
    );

    test(
      're-applies the policy across compact and expanded transitions',
      () async {
        await service.applyFor(_mediaQuery(const Size(390, 844)));
        await service.applyFor(_mediaQuery(const Size(834, 1112)));
        await service.applyFor(_mediaQuery(const Size(390, 844)));

        expect(appliedOrientations, [
          _names(_compact),
          _names(_expanded),
          _names(_compact),
        ]);
      },
    );

    test('applies the initial policy when started and stops cleanly', () async {
      await service.start();

      expect(appliedOrientations, hasLength(1));

      service.stop();
    });
  });
}

const _compact = OrientationPolicyService.compactOrientations;
const _expanded = OrientationPolicyService.expandedOrientations;

List<String> _names(List<DeviceOrientation> orientations) {
  return orientations.map((orientation) => orientation.toString()).toList();
}

MediaQueryData _mediaQuery(
  Size size, {
  List<DisplayFeature> displayFeatures = const [],
}) {
  return MediaQueryData(size: size, displayFeatures: displayFeatures);
}
