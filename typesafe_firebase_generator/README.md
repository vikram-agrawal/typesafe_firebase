A library to put wrapper arround firebase to access it in typesafe elegant way.


## Usage
Refer [Github Repo](https://github.com/vikram-agrawal/typesafe_firebase_examples) for example usage.

pubspec.yaml
```yaml
dependencies:
  typesafe_firebase_core: ^0.0.3

dev_dependencies:
  typesafe_firebase_generator: ^0.0.3
```

Example:
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
