import 'package:project_tweety/data/dtos/card/card.dto.dart';

/// How one Card's push ended.
enum CardPushOutcome {
  /// The server confirmed the write.
  confirmed,

  /// The server could not be reached in time. Retrying later may succeed.
  networkFailure,

  /// The server refused the write, or it failed for another reason.
  failure,
}

/// The Account's copy of its Cards, written by a sync and never read as
/// truth ([ADR-0007](../../../../docs/decisions/0007-cards-local-source-of-truth.md)).
abstract class CardsRemoteDataSource {
  /// Pushes each Card on its own: a tombstone deletes its copy, and every
  /// other Card replaces it. Calls [onPushed] as each write settles, and
  /// returns every outcome by Card id.
  Future<Map<String, CardPushOutcome>> pushCards(
    List<CardDto> cards, {
    void Function(String cardId, CardPushOutcome outcome)? onPushed,
  });
}
