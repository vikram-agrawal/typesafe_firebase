import 'package:typesafe_firebase/firebase/firebase_provider.dart';

class FirebaseAuthService {
  static bool get isUserLoggedIn {
    return FirebaseProvider.auth.currentUser != null;
  }
}
