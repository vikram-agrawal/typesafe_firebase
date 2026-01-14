import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/models/base_model.dart';

class $Collection<T extends $Document<D>, D extends BaseModel> {
  final T Function(String id, $Collection<$Document<D>, D> collection) _creator;
  late final CollectionReference _collRef;
  final $Document<BaseModel>? _doc;

  // Accept the constructor as a parameter
  $Collection(String name, this._creator, $FirestoreDb? db, this._doc) {
    if (_doc == null) {
      _collRef = db!._firestore.collection(name);
    } else {
      _collRef = _doc._docRef.collection(name);
    }
  }

  T operator [](String id) {
    return _creator(id, this);
  }
}

abstract class $Document<T extends BaseModel> {
  late final DocumentReference<T> _docRef;

  $Document(String id, $Collection<$Document<T>, T> collection) {
    _docRef = collection._collRef
        .doc(id)
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: _toFirestore,
        );
  }

  Future<bool> get exists async {
    return (await _docRef.get()).exists;
  }

  Future<T> get data async {
    return (await _docRef.get()).data()!;
  }

  T _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final converter = BaseModel.getConverter<T>();
    return converter.fromJson(snapshot.data()!);
  }

  Map<String, Object?> _toFirestore(T value, SetOptions? options) {
    return {};
  }
}

abstract class $FirestoreDb {
  late final FirebaseFirestore _firestore;

  $FirestoreDb({String? databaseId}) {
    _firestore = FirebaseProvider.firestore(databaseId: databaseId);
  }
}
