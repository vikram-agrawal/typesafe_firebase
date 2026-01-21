import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:typesafe_firebase_core/models.dart';
import 'package:typesafe_firebase_firestore/firestore/base.dart';
import 'package:typesafe_firebase_firestore/firestore/document.dart';

/// A type-safe wrapper for a Firestore Collection.
///
/// [T] is the [$Document] proxy type which provides the API for document interactions.
/// [D] is the [BaseModel] data type representing the schema of the documents.
///
/// This class handles automatic serialization/deserialization and provides
/// optimized methods for bulk data retrieval and aggregation.
final class $Collection<T extends $Document<D>, D extends BaseModel> {
  /// The factory function used to instantiate document proxies.
  final T Function(String id, CollectionReference<D> collection, {DocumentSnapshot<D>? data}) _creator;

  /// The underlying Firestore [CollectionReference].
  final CollectionReference<D> _collRef;

  /// Internal constructor used by the generator to initialize the collection chain.
  $Collection(String name, this._creator, {$FirestoreDb? firestoreDb, $Document<BaseModel>? parentDoc})
    : _collRef = (parentDoc == null ? firestoreDb!.firestore.collection(name) : parentDoc.$docRef.collection(name))
          .withConverter<D>(fromFirestore: _fromFirestore, toFirestore: _toFirestore);

  /// Accesses a document by its [id] using the index operator.
  @useResult
  T operator [](String id) => _creator(id, _collRef);

  /// Adds a document to the collection.
  ///
  /// If [id] is provided, performs a `set` operation at that specific location.
  /// Otherwise, uses Firestore's auto-generated ID. Returns a proxy [T] for the new document.
  Future<T> add(D value, [String? id]) async {
    if (id != null) {
      await this[id].set(value);
      return _creator(id, _collRef);
    } else {
      final doc = await _collRef.add(value);
      return _creator(doc.id, _collRef);
    }
  }

  /// Returns an asynchronous stream of all documents in the collection.
  ///
  /// **Performance & Cost:**
  /// - Uses pagination with a buffer to avoid OOM crashes.
  /// - Stable cursor iteration via [FieldPath.documentId].
  /// - For large amount of documents, this stream will remain active for the duration of the transfer.
  @useResult
  Stream<T> getAll() async* {
    Query<D> query = _collRef.orderBy(FieldPath.documentId).limit(100);
    DocumentSnapshot? lastDocument;

    while (true) {
      Query<D> currentQuery = lastDocument != null ? query.startAfterDocument(lastDocument) : query;

      final snapshots = (await currentQuery.get()).docs;

      for (var doc in snapshots) {
        yield _creator(doc.id, _collRef, data: doc as DocumentSnapshot<D>);
      }

      if (snapshots.length < 100) {
        break;
      }
      lastDocument = snapshots.last;
    }
  }

  /// Returns the total number of documents in this collection.
  @useResult
  Future<int> count() async {
    final snapshot = await _collRef.count().get();
    return snapshot.count ?? 0;
  }

  static T _fromFirestore<T extends BaseModel>(DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
      BaseModel.getConverter<T>().fromJson(snapshot.data()!);

  static Map<String, Object?> _toFirestore<T extends BaseModel>(T value, _) =>
      BaseModel.getConverter<T>().toJson(value);
}
