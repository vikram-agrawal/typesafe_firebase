A library to put wrapper arround firebase to access it in typesafe elegant way.


## Usage

```dart
@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

class ClientApi extends FirebaseFunctionsService {
  ClientApi() : super(prefix: "/user");

  // Will call /user/load firebase function.
  late final loadUser = createFunction<IntData, UserProfile>("/load");
}

class Run {
  static void main() async {
    FirebaseProvider.setConfig(region: "asia-south1");
    registerCommonModels();
    registerAllModels();
    UserProfile result = await ClientApi().loadUser(IntData());
    result.uid;
  }
}

```
