import 'package:json_annotation/json_annotation.dart';
import 'package:typesafe_firebase/functions/annotation.dart';
import 'package:typesafe_firebase/functions/base_model.dart';

@Model()
class VoidData extends BaseModel {}

@Model()
class IntData extends BaseModel {
  IntData([this.value = 0]);

  @JsonKey(name: "Value")
  int value;
}

@Model()
class StringData extends BaseModel {
  StringData([this.value = ""]);

  @JsonKey(name: "Value")
  String value;
}
