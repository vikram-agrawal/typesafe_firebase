// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map json) =>
    UserProfile()..userId = json['userId'] as String;

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{'userId': instance.userId};

InventoryItem _$InventoryItemFromJson(Map json) =>
    InventoryItem()..itemId = (json['itemId'] as num).toInt();

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{'itemId': instance.itemId};

Packet _$PacketFromJson(Map json) => Packet()
  ..id = (json['id'] as num).toInt()
  ..qty = (json['qty'] as num).toInt();

Map<String, dynamic> _$PacketToJson(Packet instance) => <String, dynamic>{
  'id': instance.id,
  'qty': instance.qty,
};

Transaction _$TransactionFromJson(Map json) => Transaction()
  ..id = (json['id'] as num).toInt()
  ..amt = (json['amt'] as num).toDouble();

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{'id': instance.id, 'amt': instance.amt};

// **************************************************************************
// ModelGenerator
// **************************************************************************

//IMPORT: test/firestore/models.dart
//==BaseModel.register<UserProfile>(
//==  toJson: UserProfileToJson,
//==  fromJson: UserProfileFromJson,
//==);

// ignore: constant_identifier_names
const UserProfileFromJson = _$UserProfileFromJson;

// ignore: constant_identifier_names
const UserProfileToJson = _$UserProfileToJson;

//IMPORT: test/firestore/models.dart
//==BaseModel.register<InventoryItem>(
//==  toJson: InventoryItemToJson,
//==  fromJson: InventoryItemFromJson,
//==);

// ignore: constant_identifier_names
const InventoryItemFromJson = _$InventoryItemFromJson;

// ignore: constant_identifier_names
const InventoryItemToJson = _$InventoryItemToJson;

//IMPORT: test/firestore/models.dart
//==BaseModel.register<Packet>(
//==  toJson: PacketToJson,
//==  fromJson: PacketFromJson,
//==);

// ignore: constant_identifier_names
const PacketFromJson = _$PacketFromJson;

// ignore: constant_identifier_names
const PacketToJson = _$PacketToJson;

//IMPORT: test/firestore/models.dart
//==BaseModel.register<Transaction>(
//==  toJson: TransactionToJson,
//==  fromJson: TransactionFromJson,
//==);

// ignore: constant_identifier_names
const TransactionFromJson = _$TransactionFromJson;

// ignore: constant_identifier_names
const TransactionToJson = _$TransactionToJson;
