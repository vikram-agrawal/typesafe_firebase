import 'package:typesafe_firebase/firebase/firebase_provider.dart';

/// A service class providing a centralized interface for Firebase Authentication.
///
/// This service abstracts interactions with the [FirebaseProvider] to manage
/// user sessions and authentication states.
class FirebaseAuthService {
  /// Returns `true` if a user is currently signed into the application.
  static bool get isUserLoggedIn {
    return FirebaseProvider.auth().currentUser != null;
  }
}
