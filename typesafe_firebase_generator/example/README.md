```dart
part 'user.model.g.dart';

@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

part 'user.schema.g.dart';

@FirestoreService("UserDataStore")
const userDataSchema = {
  'UserProfiles': (
    type: UserProfile,
    subCollections: {'AuditTrail': (type: AuditTrailEntry)},
  ),
};
```