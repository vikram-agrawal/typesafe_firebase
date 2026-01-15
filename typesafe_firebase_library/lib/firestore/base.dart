import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/models/base_model.dart';

/// A type-safe wrapper for a Firestore Collection.
///
/// [T] is the [$Document] proxy type; [D] is the [BaseModel] data type.
final class $Collection<T extends $Document<D>, D extends BaseModel> {
  /// The factory function used to instantiate document proxies.
  final T Function(String id, $Collection<$Document<D>, D> collection) _creator;

  /// The underlying Firestore [CollectionReference].
  final CollectionReference _collRef;

  /// Internal constructor used by the generator to initialize the collection chain.
  $Collection(String name, this._creator, {$FirestoreDb? firebaseDb, $Document<BaseModel>? parentDoc})
    : _collRef = parentDoc == null ? firebaseDb!._firestore.collection(name) : parentDoc._docRef.collection(name);

  /// Accesses a document by its [id] using the index operator.
  @useResult
  T operator [](String id) => _creator(id, this);
}

/// An abstract base for type-safe Document proxies.
///
/// Manages the [DocumentReference] and provides automated serialization.
abstract base class $Document<T extends BaseModel> {
  /// The internal Firestore reference with typed converters.
  final DocumentReference<T> _docRef;

  /// Initializes the document proxy with a collection context and ID.
  @internal
  $Document(String id, $Collection<$Document<T>, T> collection)
    : _docRef = collection._collRef.doc(id).withConverter<T>(fromFirestore: _fromFirestore, toFirestore: _toFirestore);

  /// Returns `true` if the document currently exists in Firestore.
  @useResult
  Future<bool> get exists async => (await _docRef.get()).exists;

  /// Fetches and deserializes the document data into type [T].
  ///
  /// Throws a [FirebaseException] if the document is missing.
  @useResult
  Future<T> get data async {
    final snapshot = await _docRef.get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Document at ${_docRef.path} does not exist.',
      );
    }
    return data;
  }

  /// Writes the provided [value] to this document location.
  Future<void> set(T value, [SetOptions? options]) => _docRef.set(value, options);

  /// Deletes the document from Firestore.
  Future<void> delete() => _docRef.delete();

  static T _fromFirestore<T extends BaseModel>(DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
      BaseModel.getConverter<T>().fromJson(snapshot.data()!);

  static Map<String, Object?> _toFirestore<T extends BaseModel>(T value, _) =>
      BaseModel.getConverter<T>().toJson(value);
}

/// The root entry point for a generated Firestore service.
abstract base class $FirestoreDb {
  /// The [FirebaseFirestore] instance shared across this database service.
  final FirebaseFirestore _firestore;

  /// Standard constructor for the service, typically called by the generator.
  $FirestoreDb({String? databaseId}) : _firestore = FirebaseProvider.firestore(databaseId: databaseId);
}
