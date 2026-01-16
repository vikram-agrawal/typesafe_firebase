import 'package:cloud_functions/cloud_functions.dart';
import 'package:typesafe_firebase_core/models.dart';
import 'package:typesafe_firebase_core/typesafe_firebase.dart';
import 'package:typesafe_firebase_functions/functions/exceptions.dart';

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
  /// [prefix] is used only for [createFunction] not for [createFunctionFromUrl]
  /// or [createFunctionFromUri]
  ///
  /// An optional [region] can be provided to target specific Cloud Function locations.
  FirebaseFunctionsService({String prefix = "", String? region}) {
    _prefix = prefix;
    _functions = FirebaseProvider.functions(region);
  }

  /// Creates a typesafe callable function wrapper.
  ///
  /// This method returns a specialized closure that acts as a bridge between
  /// local [BaseModel] objects and remote Cloud Functions.
  ///
  /// ### The Returned Function
  /// This closure wraps the Firebase function call to [_prefix] + [path].
  /// It handles the transformation of a [RequestT] input into a [ResponseT] output.
  /// When [isAnonymous] is false, it performs a pre-call authentication check to
  /// prevent unauthorized network overhead.
  ///
  /// ### Parameters:
  /// * [path]: The specific endpoint name of the Cloud Function.
  /// * [isAnonymous]: If set to `false`, the returned function will throw an
  ///   [UnauthenticatedCallException] if the current user is a guest or not logged in.
  ///   Defaults to `true`.
  ///
  /// ### Exceptions thrown by the returned function:
  /// * [UnauthenticatedCallException]: Thrown if local auth validation fails or if
  ///   the backend returns an 'unauthenticated' error code.
  /// * [TypesafeFirebaseException]: Thrown for general function failures or
  ///   unhandled [Exception]s.
  /// * [TypeNotRegisteredException]: Thrown via [BaseModel] if the converters for
  ///   [RequestT] or [ResponseT] are not found in the registry.
  Future<ResponseT> Function(RequestT req, {HttpsCallableOptions? options})
  createFunction<RequestT extends BaseModel, ResponseT extends BaseModel>(String path, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallable("$_prefix$path", options: options);
    }

    return _createFunction(getCallable, "$_prefix$path", isAnonymous);
  }

  /// Creates a typesafe callable function wrapper.
  ///
  /// Refer [createFunction] for details.
  Future<ResponseT> Function(RequestT req, {HttpsCallableOptions? options})
  createFunctionFromUri<RequestT extends BaseModel, ResponseT extends BaseModel>(Uri uri, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallableFromUri(uri, options: options);
    }

    return _createFunction(getCallable, uri.toString(), isAnonymous);
  }

  /// Creates a typesafe callable function wrapper.
  ///
  /// Refer [createFunction] for details.
  Future<ResponseT> Function(RequestT req, {HttpsCallableOptions? options}) createFunctionFromUrl<
    RequestT extends BaseModel,
    ResponseT extends BaseModel
  >(String url, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallableFromUrl(url, options: options);
    }

    return _createFunction(getCallable, url, isAnonymous);
  }

  Future<ResponseT> Function(RequestT req, {HttpsCallableOptions? options}) _createFunction<
    RequestT extends BaseModel,
    ResponseT extends BaseModel
  >(HttpsCallable Function(HttpsCallableOptions?) getCallable, String path, bool isAnonymous) {
    return ((RequestT req, {HttpsCallableOptions? options}) async {
      try {
        // Validation: Check authentication if required
        if (!isAnonymous && FirebaseAuthService.isAnonymous) {
          throw UnauthenticatedCallException("Authentication required for function: $path");
        }

        final HttpsCallable callable = getCallable(options);
        final reqJson = BaseModel.getConverter<RequestT>().toJson(req);
        final HttpsCallableResult result = await callable.call(reqJson);

        return BaseModel.getConverter<ResponseT>().fromJson(result.data);
      } on TypesafeFirebaseException catch (_) {
        rethrow;
      } on FirebaseFunctionsException catch (e) {
        if (e.code == "unauthenticated") {
          throw UnauthenticatedCallException(e.message ?? "", innerException: e);
        } else {
          throw TypesafeFirebaseException(code: "functions/${e.code}", innerException: e);
        }
      } on Exception catch (e) {
        throw TypesafeFirebaseException(code: "functions/unknown", innerException: e);
      }
    });
  }
}
