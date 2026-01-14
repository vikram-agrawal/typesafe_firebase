import 'package:typesafe_firebase/firestore/annotation.dart';
import 'package:typesafe_firebase/typesafe_firebase.dart';

import 'models.dart';

part 'schema.g.dart';

@FirestoreService()
const userClientSchema = {
  'UserProfiles': (
    type: UserProfile,
    subCollections: {'AuditTrails': (type: UserProfile)},
  ),
  'Inventory': (
    type: InventoryItem,
    subCollections: {
      'Packets': (
        type: Packet,
        subCollections: {
          'Transactions': (
            type: Transaction,
            subCollections: {'Id': (type: StringData)},
          ),
        },
      ),
    },
  ),
};
