part of 'other_bloc.dart';

enum OtherStatus { initial, loading, success, failure }

@freezed
class OtherState with _$OtherState {
  const OtherState._();

  const factory OtherState({
    @Default(OtherStatus.initial) OtherStatus status,
    @Default(<OtherCardItem>[]) List<OtherCardItem> items,
    String? errorMessage,
  }) = _OtherState;

  bool get isInitial => status == OtherStatus.initial;

  bool get isLoading => status == OtherStatus.loading;

  bool get isSuccess => status == OtherStatus.success;

  bool get isFailure => status == OtherStatus.failure;

  bool get hasItems => items.isNotEmpty;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);

  @override
  // TODO: implement errorMessage
  String? get errorMessage => throw UnimplementedError();

  @override
  // TODO: implement items
  List<OtherCardItem> get items => throw UnimplementedError();

  @override
  // TODO: implement status
  OtherStatus get status => throw UnimplementedError();
}
