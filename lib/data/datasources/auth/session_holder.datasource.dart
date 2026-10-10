/// Who owns the Cards that a query reads or writes: the signed-in Account.
///
/// It is read at query time and holds no copy of its own. It is separate from
/// `AuthRepository`, so a datasource never depends on a repository
/// ([ADR-0008](../../../../docs/decisions/0008-cards-are-owned-by-the-signed-in-account.md)).
abstract class SessionHolder {
  /// The signed-in Account's uid. Throws a [StateError] when nobody is
  /// signed in, so a missing uid never reaches a query as null.
  String get uid;
}
