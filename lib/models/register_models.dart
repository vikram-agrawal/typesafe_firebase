import "package:typesafe_firebase/models/base_model.dart";
import "package:typesafe_firebase/models/common_models.dart";

/// Registers the core data transfer objects (DTOs) with the [BaseModel] registry.
///
/// This function initializes serialization and deserialization logic for common
/// types used across the application. It maps the generated JSON serialization
/// functions (`toJson` and `fromJson`) to their respective types:
///
/// * [VoidData]: Used for operations that return no content.
/// * [IntData]: Used for operations returning a single integer value.
/// * [StringData]: Used for operations returning a single string value.
///
/// This registration must be called during the application startup sequence,
/// typically before any network requests or data persistence operations occur.
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
