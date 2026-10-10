import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@module
abstract class FirestoreModule {
  // SQLite is the source of truth, so Firestore keeps no durable write queue
  // of its own beside it.
  @lazySingleton
  FirebaseFirestore get firestore =>
      FirebaseFirestore.instance
        ..settings = const Settings(persistenceEnabled: false);
}
