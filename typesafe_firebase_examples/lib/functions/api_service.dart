import 'package:typesafe_firebase/typesafe_firebase.dart';
import 'package:typesafe_firebase/models.dart';
import 'package:typesafe_firebase_examples/functions/models.dart';

class ExampleApiService extends FirebaseFunctionsService {
  ExampleApiService() : super(prefix: "user", region: "asia-south1");

  late final load = createFunction<StringData, UserProfile>("/load");
}
