import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:project_tweety/data/repositories/card/cards.repository.dart';

/// In-memory [CardsRepository] used across widget and bloc tests.
///
/// The default constructor is a working repository backed by a mutable list.
/// Every operation records a call count, and any operation can be made to fail
/// by passing the matching error. The two named constructors cover the cases
/// that cannot be expressed that way: a collection-only repository whose detail
/// reads are a tripwire, and a gated repository whose writes stay pending until
/// the test completes them.
class FakeCardsRepository implements CardsRepository {
  FakeCardsRepository({
    List<Card>? cards,
    this.readError,
    this.createError,
    this.updateError,
    this.deleteError,
  }) : _cards = List<Card>.of(cards ?? sampleCards),
       _readCards = null,
       _detailReadsSupported = true,
       _gateWrites = false;

  /// Reads the collection through [readCards] and treats any detail read as a
  /// failure, for tests asserting that details derive from the loaded
  /// collection rather than a second round trip.
  FakeCardsRepository.collectionOnly(Future<List<Card>> Function() readCards)
    : _cards = <Card>[],
      _readCards = readCards,
      _detailReadsSupported = false,
      _gateWrites = false,
      readError = null,
      createError = null,
      updateError = null,
      deleteError = null;

  /// Leaves every write pending until [completeCreate], [completeUpdate], or
  /// [completeDelete] is called, so tests can assert in-flight state.
  FakeCardsRepository.gated()
    : _cards = <Card>[],
      _readCards = null,
      _detailReadsSupported = true,
      _gateWrites = true,
      readError = null,
      createError = null,
      updateError = null,
      deleteError = null;

  final List<Card> _cards;
  final Future<List<Card>> Function()? _readCards;
  final bool _detailReadsSupported;
  final bool _gateWrites;

  final Object? readError;
  final Object? createError;
  final Object? updateError;
  final Object? deleteError;

  var collectionReadCount = 0;
  var detailReadCount = 0;
  var createRequestCount = 0;
  var updateRequestCount = 0;
  var deleteRequestCount = 0;

  final Completer<Card> _createCompleter = Completer<Card>();
  final Completer<Card> _updateCompleter = Completer<Card>();
  final Completer<void> _deleteCompleter = Completer<void>();

  List<Card> get cards => List<Card>.unmodifiable(_cards);

  @override
  Future<List<Card>> getCards() {
    collectionReadCount += 1;

    final readCards = _readCards;
    if (readCards != null) {
      return readCards();
    }

    final error = readError;
    if (error != null) {
      return Future<List<Card>>.error(error);
    }

    return Future<List<Card>>.value(List<Card>.of(_cards));
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    detailReadCount += 1;

    if (!_detailReadsSupported) {
      throw UnsupportedError('Details must derive from the loaded collection.');
    }

    for (final card in _cards) {
      if (card.id == cardId) {
        return card;
      }
    }

    return null;
  }

  @override
  Future<Card> createCard(CardDraft draft) {
    createRequestCount += 1;

    final error = createError;
    if (error != null) {
      return Future<Card>.error(error);
    }

    if (_gateWrites) {
      return _createCompleter.future;
    }

    final card = Card(
      id: 'created-card',
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
    _cards.add(card);

    return Future<Card>.value(card);
  }

  void completeCreate([Card? card]) {
    _createCompleter.complete(
      card ??
          const Card(
            id: 'created-card',
            title: 'New title',
            description: 'New description',
          ),
    );
  }

  @override
  Future<Card> updateCard({required String cardId, required CardDraft draft}) {
    updateRequestCount += 1;

    final error = updateError;
    if (error != null) {
      return Future<Card>.error(error);
    }

    if (_gateWrites) {
      return _updateCompleter.future;
    }

    final card = Card(
      id: cardId,
      title: draft.title.trim(),
      description: draft.description.trim(),
    );
    final index = _cards.indexWhere((existing) => existing.id == cardId);
    if (index >= 0) {
      _cards[index] = card;
    }

    return Future<Card>.value(card);
  }

  void completeUpdate(Card card) => _updateCompleter.complete(card);

  @override
  Future<void> deleteCard(String cardId) {
    deleteRequestCount += 1;

    final error = deleteError;
    if (error != null) {
      return Future<void>.error(error);
    }

    if (_gateWrites) {
      return _deleteCompleter.future;
    }

    _cards.removeWhere((card) => card.id == cardId);

    return Future<void>.value();
  }

  void completeDelete() => _deleteCompleter.complete();

  /// The ten cards the app ships with, shared by every test that needs a
  /// populated list.
  static final List<Card> sampleCards = List<Card>.generate(
    10,
    (index) => Card(
      id: 'card-${index + 1}',
      title: 'Card Title ${index + 1}',
      description:
          'This is the body copy for card number ${index + 1}. '
          'You can replace this with whatever description you want.',
    ),
    growable: false,
  );
}

/// Swaps the registered [CardsRepository] for [repository].
///
/// Only meaningful for tests that drive `MyApp`, which resolves its own
/// dependencies from `GetIt`.
void replaceCardsRepository(CardsRepository repository) {
  GetIt.I
    ..unregister<CardsRepository>()
    ..registerLazySingleton<CardsRepository>(() => repository);
}
