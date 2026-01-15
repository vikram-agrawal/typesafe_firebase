import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:typesafe_firebase_core/models.dart';
import 'package:typesafe_firebase_core/typesafe_firebase.dart';

/// A type-safe wrapper for a Firestore Collection.
///
/// [T] is the [$Document] proxy type; [D] is the [BaseModel] data type.
final class $Collection<T extends $Document<D>, D extends BaseModel> {
  /// The factory function used to instantiate document proxies.
  final T Function(String id, $Collection<$Document<D>, D> collection) _creator;

  /// The underlying Firestore [CollectionReference].
  final CollectionReference<D> _collRef;

  /// Internal constructor used by the generator to initialize the collection chain.
  $Collection(String name, this._creator, {$FirestoreDb? firestoreDb, $Document<BaseModel>? parentDoc})
    : _collRef = (parentDoc == null ? firestoreDb!._firestore.collection(name) : parentDoc._docRef.collection(name))
          .withConverter<D>(fromFirestore: _fromFirestore, toFirestore: _toFirestore);

  /// Accesses a document by its [id] using the index operator.
  @useResult
  T operator [](String id) => _creator(id, this);

  /// Adds a document to collection.
  Future<T> add(D value, [String? id]) async {
    if (id != null) {
      await this[id].set(value);
      return _creator(id, this);
    } else {
      final doc = await _collRef.add(value);
      return _creator(doc.id, this);
    }
  }

  static T _fromFirestore<T extends BaseModel>(DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
      BaseModel.getConverter<T>().fromJson(snapshot.data()!);

  static Map<String, Object?> _toFirestore<T extends BaseModel>(T value, _) =>
      BaseModel.getConverter<T>().toJson(value);
}

/// An abstract base for type-safe Document proxies.
///
/// Manages the [DocumentReference] and provides automated serialization.
abstract base class $Document<T extends BaseModel> {
  /// The internal Firestore reference with typed converters.
  final DocumentReference<T> _docRef;

  /// Initializes the document proxy with a collection context and ID.
  @internal
  $Document(String id, $Collection<$Document<T>, T> collection) : _docRef = collection._collRef.doc(id);

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

  @useResult
  String get id {
    return _docRef.id;
  }

  /// Writes the provided [value] to this document location.
  Future<void> set(T value, [SetOptions? options]) => _docRef.set(value, options);

  /// Deletes the document from Firestore.
  Future<void> delete() => _docRef.delete();
}

/// The root entry point for a generated Firestore service.
abstract base class $FirestoreDb {
  /// The [FirebaseFirestore] instance shared across this database service.
  final FirebaseFirestore _firestore;

  /// Standard constructor for the service, typically called by the generator.
  $FirestoreDb({String? databaseId}) : _firestore = FirebaseProvider.firestore(databaseId: databaseId);
}
