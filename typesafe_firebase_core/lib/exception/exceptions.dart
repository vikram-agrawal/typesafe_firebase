import 'package:typesafe_firebase_core/exception/base_exception.dart';

/// Exception thrown when a model is not registered
/// within the application's serialization or factory mapping.
class TypeNotRegisteredException extends TypesafeFirebaseException {
  /// Creates a new [TypeNotRegisteredException] for the specified [type].
  ///
  /// The [type] parameter should be the name of the class that was
  /// not found in the registry.
  TypeNotRegisteredException(String type)
    : super(code: "basemodel/typeunregistered", message: "Type $type is not registered. Call registerAllModesl();.");
}
