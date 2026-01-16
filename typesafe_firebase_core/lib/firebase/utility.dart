import 'dart:convert';

import 'package:typesafe_firebase_core/typesafe_firebase.dart';

Map<String, dynamic> getMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is String) {
    return jsonDecode(data);
  }

  throw TypesafeFirebaseException(
    code: "core/noncompatibletype",
    message: "${data.runtimeType} is not convertible to Map<String, Dynamic>.",
  );
}
