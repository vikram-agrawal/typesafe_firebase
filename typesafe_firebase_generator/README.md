A library to put wrapper arround firebase to access it in typesafe elegant way.


## Usage
Refer [Github Repo](https://github.com/vikram-agrawal/typesafe_firebase_examples) for example usage.

Add to build.yaml
```yaml
targets:
  $default:
    builders:
      typesafe_firebase_generator:registration_builder:
        enabled: true
```

pubspec.yaml
```yaml
dependencies:
  typesafe_firebase_core: ^0.0.2

dev_dependencies:
  build_runner: ^2.10.4
  typesafe_firebase_generator: ^0.0.2
```

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
