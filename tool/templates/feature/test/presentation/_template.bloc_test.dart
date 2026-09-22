// Reference only: adapt this at the feature's public BLoC seam during TDD.
// Do not copy it unchanged into a generated feature.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemplateBloc', () {
    blocTest<TemplateBloc, TemplateState>(
      'emits loading then success when TemplateStarted completes',
      build: () => TemplateBloc(_FakeTemplateRepository()),
      act: (bloc) => bloc.add(const TemplateStarted()),
      expect: () => const <TemplateState>[
        TemplateState(status: TemplateStatus.loading),
        TemplateState(status: TemplateStatus.success),
      ],
    );
  });
}

final class _FakeTemplateRepository implements TemplateRepository {
  @override
  Future<void> fetchTemplate() async {}
}
