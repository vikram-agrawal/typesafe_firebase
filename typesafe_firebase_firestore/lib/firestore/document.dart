import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:typesafe_firebase_core/models.dart';

/// An abstract base for type-safe Document proxies.
///
/// Manages a specific [DocumentReference] and provides a cached interface
/// for accessing document data and metadata.
abstract base class $Document<T extends BaseModel> {
  /// The internal Firestore reference with typed converters.
  final DocumentReference<T> _docRef;

  /// Cached snapshot data to prevent redundant network reads.
  DocumentSnapshot<T>? _data;

  /// Tracks active network requests to deduplicate concurrent calls to [data] or [exists].
  Future<DocumentSnapshot<T>>? _pendingLoad;

  /// Deduplicates multiple simultaneous fetch requests into a single future.
  ///
  /// Ensures that calling [exists] and [data] at the same time only bills for 1 read.
  Future<DocumentSnapshot<T>> _getOrFetch() {
    if (_data != null) return Future.value(_data!);
    return _pendingLoad ??= _docRef.get().whenComplete(() => _pendingLoad = null).then((v) => _data = v);
  }

  /// Initializes the document proxy with a collection context and ID.
  @internal
  $Document(String id, CollectionReference<T> collection, {DocumentSnapshot<T>? data})
    : _docRef = collection.doc(id),
      _data = data;

  /// Returns `true` if the document exists in the database.
  ///
  /// Uses cached data if available, otherwise performs a network fetch.
  @useResult
  Future<bool> get exists async => (await _getOrFetch()).exists;

  /// Fetches and deserializes the document data into type [T].
  ///
  /// **Throws:** [FirebaseException] with code 'not-found' if the document is missing.
  @useResult
  Future<T> get data async {
    final snap = await _getOrFetch();
    final data = snap.data();
    if (!snap.exists || data == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Document at ${_docRef.path} does not exist.',
      );
    }
    return data;
  }

  /// Receive events when doc changes in form of stream.
  @useResult
  Stream<T> get changeEvents async* {
    await for (final change in _docRef.snapshots()) {
      if (change.exists) {
        yield change.data()!;
      }
    }
  }

  /// The unique Firestore document ID.
  @useResult
  String get id {
    return _docRef.id;
  }

  // ignore: invalid_internal_annotation
  @internal
  DocumentReference<T> get $docRef => _docRef;

  /// Writes the provided [value] to this document location.
  Future<void> set(T value, [SetOptions? options]) async {
    await _docRef.set(value, options);
    _data = null;
  }

  /// Deletes the document from Firestore.
  Future<void> delete() async {
    await _docRef.delete();
    _data = null;
  }
}
