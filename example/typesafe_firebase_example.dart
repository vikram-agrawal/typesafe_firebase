import 'package:typesafe_firebase/functions/annotation.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/models/base_model.dart';
import 'package:typesafe_firebase/models/common_models.dart';
import 'package:typesafe_firebase/functions/firebase_functions.dart';
import 'package:typesafe_firebase/models/register_models.dart';

import 'models.g.dart';

part 'typesafe_firebase_example.g.dart';

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
    FirebaseProvider.setConfig(emulatorIp: "10.0.2.2");
    registerCommonModels();
    registerAllModels();
    UserProfile result = await ClientApi().loadUser(IntData(5));
    print(result.uid);
  }
}
