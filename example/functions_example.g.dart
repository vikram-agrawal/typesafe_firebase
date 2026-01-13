// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'functions_example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map json) =>
    UserProfile()..uid = json['uid'] as String;

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{'uid': instance.uid};

// **************************************************************************
// ModelGenerator
// **************************************************************************

//IMPORT: example/functions_example.dart
//==BaseModel.register<UserProfile>(
//==  toJson: UserProfileToJson,
//==  fromJson: UserProfileFromJson,
//==);

// ignore: constant_identifier_names
const UserProfileFromJson = _$UserProfileFromJson;

// ignore: constant_identifier_names
const UserProfileToJson = _$UserProfileToJson;
