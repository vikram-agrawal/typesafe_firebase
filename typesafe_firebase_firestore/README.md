A library to put wrapper arround firebase to access it in typesafe elegant way.


## Usage

Add in build.yaml:
```yaml
targets:
  $default:
    builders:
      typesafe_firebase:registration_builder:
        enabled: true
```

```dart
@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

class ClientApi extends FirebaseFunctionsService {
  ClientApi() : super(prefix: "user", region: "asia-south1");

  // Will call /user/load firebase function.
  late final loadUser = createFunction<IntData, UserProfile>("/load");
}

class Run {
  static void main() async {
    registerAllModels();
    UserProfile result = await ClientApi().loadUser(IntData(5));
    print(result.uid);
  }
}

```
