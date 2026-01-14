import 'package:typesafe_firebase/models.dart';

part 'models.g.dart';

@Model()
class UserProfile extends BaseModel {
  String uid = "";
  String? name;
}
