import 'package:cloud_functions/cloud_functions.dart';
import 'package:typesafe_firebase_core/models/base_model.dart';

abstract class TypeSafeStream<RequestT extends BaseModel, PartialT extends BaseModel, ResultT extends BaseModel> {
  void listen(
    RequestT req, {
    required void Function(PartialT data) handlePartialData,
    required void Function(ResultT data) handleResultData,
    HttpsCallableOptions? options,
  });
}
