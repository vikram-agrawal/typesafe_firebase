import 'package:cloud_functions/cloud_functions.dart';
import 'package:typesafe_firebase/auth/firebase_auth.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/functions/base_model.dart';

abstract class FirebaseFunctionsService {
  late final FirebaseFunctions _functions;
  final String prefix;

  FirebaseFunctionsService({this.prefix = ""}) {
    _functions = FirebaseProvider.functions;
  }

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

        final HttpsCallable callable = _functions.httpsCallable("$prefix$path");
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
