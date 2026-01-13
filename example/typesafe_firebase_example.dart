import 'package:typesafe_firebase/functions/annotation.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/functions/base_model.dart';
import 'package:typesafe_firebase/functions/common_models.dart';
import 'package:typesafe_firebase/functions/firebase_functions.dart';
import 'package:typesafe_firebase/functions/register_models.dart';

import 'models.g.dart';

part 'typesafe_firebase_example.g.dart';

@Model()
class UserProfile extends BaseModel {
  String uid = "";
}

class ClientApi extends FirebaseFunctionsService {
  ClientApi() : super(prefix: "user");

  // Will call /user/load firebase function.
  late final loadUser = createFunction<IntData, UserProfile>("/load");
}

class Run {
  static void main() async {
    FirebaseProvider.setConfig(region: "asia-south1");
    registerCommonModels();
    registerAllModels();
    UserProfile result = await ClientApi().loadUser(IntData(5));
    print(result.uid);
  }
}
