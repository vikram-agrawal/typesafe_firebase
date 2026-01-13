import 'package:cloud_functions/cloud_functions.dart';
import 'package:typesafe_firebase/auth/firebase_auth.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/functions/base_model.dart';

/// An abstract service that provides a typesafe interface for calling Firebase Cloud Functions.
///
/// This service leverages [BaseModel] for automated serialization of request and
/// response objects, ensuring type safety across the network boundary.
abstract class FirebaseFunctionsService {
  late final FirebaseFunctions _functions;
  late final String _prefix;

  /// Initializes the service and retrieves the [FirebaseFunctions] instance
  /// from the [FirebaseProvider].
  ///
  /// The [prefix] is an optional string prepended to all function paths
  /// created by this service instance.
  FirebaseFunctionsService({String prefix = ""}) {
    _prefix = prefix;
    _functions = FirebaseProvider.functions;
  }

  /// Creates a typesafe callable function that handles network communication.
  ///
  /// This method returns a closure that:
  /// 1. Optionally validates the authentication state.
  /// 2. Serializes the [RequestT] model into a JSON map.
  /// 3. Executes the Cloud Function via [HttpsCallable].
  /// 4. Deserializes the resulting data back into a [ResponseT] model.
  ///
  /// Parameters:
  /// * [path]: The endpoint name of the Cloud Function.
  /// * [isAuthenticated]: Whether to verify [FirebaseAuthService.isUserLoggedIn]
  /// before making the call.
  ///
  /// Throws an [Exception] if [isAuthenticated] is true but no user is signed in,
  /// or if the required [BaseModel] converters are not registered.
  ///
  /// Rethrows [FirebaseFunctionsException] or other underlying errors encountered
  /// during the call.
  Future<ResponseT> Function(RequestT req) createFunction<
    RequestT extends BaseModel,
    ResponseT extends BaseModel
  >(String path, {bool isAuthenticated = false}) {
    return ((RequestT req) async {
      try {
        // Validation: Check authentication if required
        if (isAuthenticated && !FirebaseAuthService.isUserLoggedIn) {
          throw Exception("Authentication required for function: $path");
        }

        final HttpsCallable callable = _functions.httpsCallable(
          "$_prefix$path",
        );
        final reqJson = BaseModel.getConverter<RequestT>()!.toJson(req);
        final HttpsCallableResult result = await callable.call(reqJson);

        return BaseModel.getConverter<ResponseT>()!.fromJson(result.data);
      } on FirebaseFunctionsException catch (e) {
        if (e.code == "unauthenticated") {
          throw Exception("Firebase error [${e.code}]: ${e.message}");
        } else {
          rethrow;
        }
      } catch (e) {
        rethrow;
      }
    });
  }
}
