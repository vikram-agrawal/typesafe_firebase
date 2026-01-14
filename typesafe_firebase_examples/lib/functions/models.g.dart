// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// ModelGenerator
// **************************************************************************

//IMPORT: package:typesafe_firebase_examples/functions/models.dart
//==BaseModel.register<UserProfile>(
//==  toJson: UserProfileToJson,
//==  fromJson: UserProfileFromJson,
//==);

// ignore: constant_identifier_names
const UserProfileFromJson = _$UserProfileFromJson;

// ignore: constant_identifier_names
const UserProfileToJson = _$UserProfileToJson;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map json) => UserProfile()
  ..uid = json['uid'] as String
  ..name = json['name'] as String?;

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{'uid': instance.uid, 'name': instance.name};
