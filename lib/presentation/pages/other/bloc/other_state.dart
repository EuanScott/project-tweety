part of 'other_bloc.dart';

enum OtherStatus { initial, loading, success, failure }

@freezed
class OtherState with _$OtherState {
  const factory OtherState({
    @Default(OtherStatus.initial) OtherStatus status,
    @Default(<OtherCardItem>[]) List<OtherCardItem> items,
    String? errorMessage,
  }) = _OtherState;

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
