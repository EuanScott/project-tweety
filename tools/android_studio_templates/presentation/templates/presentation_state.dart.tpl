part of '__FEATURE_NAME___bloc.dart';

enum __FEATURE_PASCAL__Status { initial, loading, success, failure }

@freezed
abstract class __FEATURE_PASCAL__State with _$__FEATURE_PASCAL__State {
  const __FEATURE_PASCAL__State._();

  const factory __FEATURE_PASCAL__State({
    @Default(__FEATURE_PASCAL__Status.initial) __FEATURE_PASCAL__Status status,
    @Default(<__ENTITY_PASCAL__>[]) List<__ENTITY_PASCAL__> items,
    String? errorMessage,
  }) = ___FEATURE_PASCAL__State;

  bool get isInitial => status == __FEATURE_PASCAL__Status.initial;

  bool get isLoading => status == __FEATURE_PASCAL__Status.loading;

  bool get isSuccess => status == __FEATURE_PASCAL__Status.success;

  bool get isFailure => status == __FEATURE_PASCAL__Status.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);
}
