import 'package:json_annotation/json_annotation.dart';
import 'package:typesafe_firebase/models/annotation.dart';
import 'package:typesafe_firebase/models/base_model.dart';

/// A data transfer object representing a null or empty response.
@Model()
class VoidData extends BaseModel {}

/// A wrapper model for a single [int] value.
@Model()
class IntData extends BaseModel {
  IntData([this.value = 0]);

  @JsonKey(name: "Value")
  int value;
}

/// A wrapper model for a single [String] value.
@Model()
class StringData extends BaseModel {
  StringData([this.value = ""]);

  @JsonKey(name: "Value")
  String value;
}
