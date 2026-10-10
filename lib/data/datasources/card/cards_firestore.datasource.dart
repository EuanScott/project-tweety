import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/core/error_reporting/error_reporting.facade.dart';
import 'package:project_tweety/data/datasources/auth/session_holder.datasource.dart';
import 'package:project_tweety/data/datasources/card/cards_remote.datasource.dart';
import 'package:project_tweety/data/dtos/card/card.dto.dart';

/// Cards in Firestore at `users/{uid}/cards/{cardId}`.
///
/// Offline persistence is off, so a write waits for the server. Each write
/// has its own timeout, so an offline push ends instead of waiting forever.
@LazySingleton(as: CardsRemoteDataSource)
class const FirestoreCardsRemoteDataSource(
  final FirebaseFirestore _firestore,
  final SessionHolder _sessionHolder,
  final ErrorReportingFacade _errorReporting,
) implements CardsRemoteDataSource {
  static const _writeTimeout = Duration(seconds: 10);
  static const _unavailableCode = 'unavailable';

  @override
  Future<Map<String, CardPushOutcome>> pushCards(
    List<CardDto> cards, {
    void Function(String cardId, CardPushOutcome outcome)? onPushed,
  }) async {
    final uid = _sessionHolder.uid;
    final outcomes = await Future.wait(
      cards.map((card) async {
        final outcome = await _push(uid, card);
        onPushed?.call(card.id, outcome);

        return MapEntry(card.id, outcome);
      }),
    );

    return Map.fromEntries(outcomes);
  }

  Future<CardPushOutcome> _push(String uid, CardDto card) async {
    final document = _firestore.doc('users/$uid/cards/${card.id}');
    final updatedAt = card.updatedAt ?? DateTime.now().toUtc();
    try {
      final write = card.syncStatus == CardSyncStatus.deleted
          ? document.delete()
          : document.set(<String, Object?>{
              'title': card.title,
              'description': card.description,
              // A Card stored before creation times existed is dated from
              // its last change, matching how the local store backfilled it.
              'createdAt': Timestamp.fromDate(card.createdAt ?? updatedAt),
              'updatedAt': Timestamp.fromDate(updatedAt),
            });
      await write.timeout(_writeTimeout);

      return CardPushOutcome.confirmed;
    } on TimeoutException {
      return CardPushOutcome.networkFailure;
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == _unavailableCode) {
        return CardPushOutcome.networkFailure;
      }

      unawaited(
        _errorReporting.recordError(
          error,
          stackTrace,
          metadata: {'code': error.code},
        ),
      );

      return CardPushOutcome.failure;
    }
  }
}
