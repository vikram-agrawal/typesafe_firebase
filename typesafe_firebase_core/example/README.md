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

Firebase.initializeApp(options: options);
FirebaseProvider.setConfig(emulatorIp: "127.0.0.1");
final auth = FirebaseProvider.auth();

```