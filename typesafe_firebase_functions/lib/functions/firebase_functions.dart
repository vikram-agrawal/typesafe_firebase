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
  /// [prefix] is used only for [createFunction] or [createStream] not for [createFunctionFromUrl],
  /// [createFunctionFromUri], [createStreamFromUrl], or [createStreamFromUri].
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
  /// This closure wraps the Firebase function call to [prefix] + [path].
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

  /// Creates a typesafe callable function wrapper using a [Uri].
  ///
  /// This is functionally identical to [createFunction], but targets the
  /// Cloud Function via a specific [uri].
  Future<ResponseT> Function(RequestT req, {HttpsCallableOptions? options})
  createFunctionFromUri<RequestT extends BaseModel, ResponseT extends BaseModel>(Uri uri, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallableFromUri(uri, options: options);
    }

    return _createFunction(getCallable, uri.toString(), isAnonymous);
  }

  /// Creates a typesafe callable function wrapper using a raw [url] string.
  ///
  /// This is functionally identical to [createFunction], but targets the
  /// Cloud Function via a direct [url].
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

        return BaseModel.getConverter<ResponseT>().fromJson(getMap(result.data));
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

  /// Creates a typesafe callable stream wrapper for Firebase Cloud Functions.
  ///
  /// This method returns a [TypeSafeStream] that facilitates real-time,
  /// chunked communication between local [BaseModel] objects and streaming
  /// remote Cloud Functions.
  ///
  /// ### The Returned Stream:
  /// The [TypeSafeStream] acts as a bridge for long-running processes.
  /// When listened to this closure wraps the Firebase stream call to [prefix] + [path].
  /// It handles the transformation of a [RequestT] input into a [ResponsePartial] & [ResponseResult] output.
  /// When [isAnonymous] is false, it performs a pre-call authentication check to
  /// prevent unauthorized network overhead.
  /// Note: Stream is not fetched until listened to.
  ///
  /// ### Parameters:
  /// * [path]: The specific endpoint name of the Cloud Function, prepended with [_prefix].
  /// * [isAnonymous]: If set to `false`, attempting to listen to the stream will throw an
  ///   [UnauthenticatedCallException] if the current user is not fully signed in.
  ///   Defaults to `true`.
  ///
  /// ### Exceptions:
  /// * [UnauthenticatedCallException]: Thrown if auth requirements are not met.
  /// * [TypeNotRegisteredException]: Thrown if converters for any of the generic types
  ///   are missing from the registry.
  /// * [TypesafeFirebaseException]: Thrown for network or backend-specific errors.

  TypeSafeStream<RequestT, ResponsePartial, ResponseResult> createStream<
    RequestT extends BaseModel,
    ResponsePartial extends BaseModel,
    ResponseResult extends BaseModel
  >(String path, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallable("$_prefix$path", options: options);
    }

    return TypeSafeStreamImpl<RequestT, ResponsePartial, ResponseResult>(getCallable, "$_prefix$path", isAnonymous);
  }

  /// Creates a typesafe callable stream wrapper using a [Uri].
  ///
  /// This is functionally identical to [createStream], but targets the
  /// Cloud Function via a specific [uri].
  TypeSafeStream<RequestT, ResponsePartial, ResponseResult> createStreamFromUri<
    RequestT extends BaseModel,
    ResponsePartial extends BaseModel,
    ResponseResult extends BaseModel
  >(Uri uri, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallableFromUri(uri, options: options);
    }

    return TypeSafeStreamImpl<RequestT, ResponsePartial, ResponseResult>(getCallable, uri.toString(), isAnonymous);
  }

  /// Creates a typesafe callable stream wrapper using a raw [url] string.
  ///
  /// This is functionally identical to [createStream], but targets the
  /// Cloud Function via a direct [url].
  TypeSafeStream<RequestT, ResponsePartial, ResponseResult> createStreamFromUrl<
    RequestT extends BaseModel,
    ResponsePartial extends BaseModel,
    ResponseResult extends BaseModel
  >(String url, {bool isAnonymous = true}) {
    HttpsCallable getCallable(HttpsCallableOptions? options) {
      return _functions.httpsCallableFromUrl(url, options: options);
    }

    return TypeSafeStreamImpl<RequestT, ResponsePartial, ResponseResult>(getCallable, url, isAnonymous);
  }
}

class TypeSafeStreamImpl<
  RequestT extends BaseModel,
  ResponsePartial extends BaseModel,
  ResponseResult extends BaseModel
>
    extends TypeSafeStream<RequestT, ResponsePartial, ResponseResult> {
  final HttpsCallable Function(HttpsCallableOptions?) getCallable;
  final String path;
  final bool isAnonymous;
  TypeSafeStreamImpl(this.getCallable, this.path, this.isAnonymous);

  @override
  void listen(
    RequestT req, {
    required void Function(ResponsePartial data) handlePartialData,
    required void Function(ResponseResult data) handleResultData,
    HttpsCallableOptions? options,
  }) {
    try {
      // Validation: Check authentication if required
      if (!isAnonymous && FirebaseAuthService.isAnonymous) {
        throw UnauthenticatedCallException("Authentication required for function: $path");
      }

      final HttpsCallable callable = getCallable(options);
      final reqJson = BaseModel.getConverter<RequestT>().toJson(req);
      final Stream<StreamResponse> result = callable.stream(reqJson);

      final partialConverter = BaseModel.getConverter<ResponsePartial>();
      final resultConverter = BaseModel.getConverter<ResponseResult>();

      result.listen((response) {
        if (response is Chunk) {
          handlePartialData(partialConverter.fromJson(getMap(response.partialData)));
        } else if (response is Result) {
          handleResultData(resultConverter.fromJson(getMap(response.result.data)));
        }
      });
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
  }
}
