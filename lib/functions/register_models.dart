// GENERATED CODE - DO NOT MODIFY
import "package:typesafe_firebase/functions/base_model.dart";
import "package:typesafe_firebase/functions/common_models.dart";

void registerCommonModels() {
  BaseModel.register<VoidData>(
    toJson: _$VoidDataToJson,
    fromJson: _$VoidDataFromJson,
  );
  BaseModel.register<IntData>(
    toJson: _$IntDataToJson,
    fromJson: _$IntDataFromJson,
  );
  BaseModel.register<StringData>(
    toJson: _$StringDataToJson,
    fromJson: _$StringDataFromJson,
  );
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoidData _$VoidDataFromJson(Map<String, dynamic> json) => VoidData();

Map<String, dynamic> _$VoidDataToJson(VoidData instance) => <String, dynamic>{};

IntData _$IntDataFromJson(Map<String, dynamic> json) =>
    IntData()..value = (json['Value'] as num).toInt();

Map<String, dynamic> _$IntDataToJson(IntData instance) => <String, dynamic>{
  'Value': instance.value,
};

StringData _$StringDataFromJson(Map<String, dynamic> json) =>
    StringData()..value = json['Value'] as String;

Map<String, dynamic> _$StringDataToJson(StringData instance) =>
    <String, dynamic>{'Value': instance.value};
