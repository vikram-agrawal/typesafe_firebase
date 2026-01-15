```dart
@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

class ExampleApiService extends FirebaseFunctionsService {
  ExampleApiService() : super(prefix: "userClient/user", region: "asia-south1");

  late final load = createFunction<StringData, UserProfile>("/load");
}


final apiService = ExampleApiService();
Future<UserProfile> getUserName(String userId) async {
  UserProfile profile = await apiService.load(StringData(userId));
  return profile ?? UserProfile();
}
```