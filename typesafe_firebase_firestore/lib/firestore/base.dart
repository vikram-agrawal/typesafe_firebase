import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:typesafe_firebase_core/typesafe_firebase.dart';

/// The root entry point for a generated Firestore service.
abstract base class $FirestoreDb {
  /// The [FirebaseFirestore] instance shared across this database service.
  final FirebaseFirestore _firestore;

  /// Standard constructor for the service, typically called by the generator.
  $FirestoreDb({String? databaseId}) : _firestore = FirebaseProvider.firestore(databaseId: databaseId);

  FirebaseFirestore get firestore => _firestore;
}
