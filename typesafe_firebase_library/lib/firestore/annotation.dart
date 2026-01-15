import 'package:meta/meta_meta.dart';

/// Annotation used to generate a type-safe Firestore Data Access Object (DAO).
///
/// Applying this to a [Map] schema triggers a generator to create a class
/// (named by [className]) that provides nested, fluent access to Firestore
/// collections and documents with full type safety.
///
/// ### Example
/// ```dart
/// @FirestoreService("UserClientStore")
/// const userClientSchema = {
///   'UserProfiles': (
///     type: UserProfile,
///     subCollections: {
///       'AuditTrail': (type: AuditTrailEntry),
///     },
///   ),
/// };
/// ```
///
/// ### Generated Usage
/// The generator produces a recursive proxy chain allowing for syntax like:
/// ```dart
/// // Returns a Future<UserProfile>
/// final profile = await UserClientStore().UserProfiles["id"].data;
///
/// // Accesses nested sub-collections
/// final trail = await UserClientStore()
///     .UserProfiles["id"]
///     .AuditTrail["log_01"]
///     .data;
/// ```
@Target({TargetKind.topLevelVariable})
class FirestoreService {
  /// The name of the generated accessor class (e.g., "UserClientStore").
  final String className;

  /// Creates a [FirestoreService] annotation.
  ///
  /// The [className] must be a valid Dart class name in PascalCase.
  const FirestoreService(this.className);
}
