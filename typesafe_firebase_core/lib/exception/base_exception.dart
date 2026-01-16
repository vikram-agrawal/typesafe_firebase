/// An implementation of [Exception] that provides a structured way
/// to handle Typesafe Firebase-related errors with optional codes and messages.
class TypesafeFirebaseException implements Exception {
  late final String? _code;
  late final String? _message;
  late final Exception? _innerException;

  /// Creates a new [TypesafeFirebaseException].
  ///
  /// * [code]: An optional error code (e.g., 'auth/user-not-found').
  /// * [message]: A human-readable string describing the error.
  /// * [innerException]: An optional underlying [Exception] that caused this error.
  TypesafeFirebaseException({String? code, String? message, Exception? innerException}) {
    _code = code;
    _message = message;
  }

  /// Returns a formatted string containing the error code and message.
  @override
  String toString() {
    final String prefix = _code == null ? "Exception" : "Exception ($_code):";
    if (_message == null) {
      if (_innerException == null) {
        return prefix;
      } else {
        return "$prefix : ${_innerException.toString()}";
      }
    } else {
      return "$prefix : $_message";
    }
  }

  /// The machine-readable error code associated with this exception.
  String? get code => _code;

  /// The human-readable description of the error.
  String? get message => toString();

  /// The original [Exception] that triggered this error, if any.
  Exception? get innerException => _innerException;
}
