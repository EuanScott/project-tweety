part of 'card_details.bloc.dart';

enum CardDetailsStatus { initial, loading, success, missing, failure }

@freezed
abstract class CardDetailsState with _$CardDetailsState {
  const CardDetailsState._();

  const factory CardDetailsState({
    @Default(CardDetailsStatus.initial) CardDetailsStatus status,
    String? cardId,
    Card? card,
    String? errorMessage,
  }) = _CardDetailsState;

  bool get isInitial => status == CardDetailsStatus.initial;

  bool get isLoading => status == CardDetailsStatus.loading;

  bool get isSuccess => status == CardDetailsStatus.success;

  bool get isMissing => status == CardDetailsStatus.missing;

  bool get isFailure => status == CardDetailsStatus.failure;

  bool get hasError => (errorMessage?.isNotEmpty ?? false);
}
