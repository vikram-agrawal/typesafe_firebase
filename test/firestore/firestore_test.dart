import 'package:flutter_test/flutter_test.dart';
import 'package:typesafe_firebase/firestore/annotation.dart';

import 'models.dart';

part 'firestore_test.g.dart';

@FirestoreService()
const userClientSchema = {
  'UserProfiles': (
    type: UserProfile,
    subCollections: {'AuditTrail': (type: UserProfile)},
  ),
  'Inventory': (
    type: InventoryItem,
    subCollections: {
      'Packets': (
        type: Packet,
        subCollections: {'Transactions': (type: Transaction)},
      ),
    },
  ),
};

void main() {
  group('Firestore', () {
    test('Define schema', () async {
      (await userClientStore().UserProfiles("a").AuditTrails("1").data());
    });
  });
}

// ignore: camel_case_types
class userClientStore {
  // expr: SetOrMapLiteralImpl - {'UserProfiles' : {'type' : UserProfile, 'AuditTrail' : {'type' : 'UserProfile'}}, 'Inventory' : {'type' : InventoryItem, 'Packets' : {'type' : Packet, 'Transactions' : {'type' : Transaction}}}}
  // Nested Map structure
  // ignore: non_constant_identifier_names
  final $Collection<$UserProfilesDoc> UserProfiles =
      $Collection<$UserProfilesDoc>($UserProfilesDoc.new);
  // Nested Map structure
  // ignore: non_constant_identifier_names
  Map<String, dynamic> Inventory = {};
}

class $Collection<T> {
  final T Function() creator;

  // Accept the constructor as a parameter
  $Collection(this.creator);

  T createInstance() {
    return creator(); // Calls the passed constructor
  }

  T call(String id) {
    return createInstance();
  }
}

class $UserProfilesDoc extends $Document<UserProfile> {
  // ignore: non_constant_identifier_names
  final AuditTrails = $Collection<$AuditTrailsDoc>($AuditTrailsDoc.new);
}

class $AuditTrailsDoc extends $Document<UserProfile> {}

class $Document<T> {
  Future<bool> exists() async {
    return true;
  }

  Future<T> data() async {
    return {} as T;
  }
}
