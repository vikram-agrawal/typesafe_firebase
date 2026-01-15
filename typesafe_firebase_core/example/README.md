```dart
@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

@FirestoreService("UserDataStore")
const userDataSchema = {
  'UserProfiles': (
    type: UserProfile,
    subCollections: {'AuditTrail': (type: AuditTrailEntry)},
  ),
};
```