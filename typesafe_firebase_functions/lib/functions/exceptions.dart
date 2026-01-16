import 'package:typesafe_firebase_core/typesafe_firebase.dart';

/// Exception thrown when a call is made to a resource or function that
/// requires an authenticated user, but the current user is not signed in.
class UnauthenticatedCallException extends TypesafeFirebaseException {
  /// Creates a new [UnauthenticatedCallException] with a custom [message].
  ///
  /// * [message]: A human-readable description of the specific operation that failed.
  /// * [innerException]: An optional underlying [Exception] that triggered this error.
  UnauthenticatedCallException(String message, {super.innerException})
    : super(code: "functions/unauthenticatedCall", message: message);
}
