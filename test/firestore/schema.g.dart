// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

class UserClientStore extends $FirestoreDb {
  // ignore: non_constant_identifier_names
  late final UserProfiles = $Collection<$UserProfilesDoc, UserProfile>(
    'UserProfiles',
    $UserProfilesDoc.new,
    this,
    null,
  );

  // ignore: non_constant_identifier_names
  late final Inventory = $Collection<$InventoryDoc, InventoryItem>(
    'Inventory',
    $InventoryDoc.new,
    this,
    null,
  );
}

class $UserProfilesDoc extends $Document<UserProfile> {
  $UserProfilesDoc(super.id, super.collection);

  // ignore: non_constant_identifier_names
  late final AuditTrails = $Collection<$AuditTrailsDoc, UserProfile>(
    'AuditTrails',
    $AuditTrailsDoc.new,
    null,
    this,
  );
}

class $AuditTrailsDoc extends $Document<UserProfile> {
  $AuditTrailsDoc(super.id, super.collection);
}

class $InventoryDoc extends $Document<InventoryItem> {
  $InventoryDoc(super.id, super.collection);

  // ignore: non_constant_identifier_names
  late final Packets = $Collection<$PacketsDoc, Packet>(
    'Packets',
    $PacketsDoc.new,
    null,
    this,
  );
}

class $PacketsDoc extends $Document<Packet> {
  $PacketsDoc(super.id, super.collection);

  // ignore: non_constant_identifier_names
  late final Transactions = $Collection<$TransactionsDoc, Transaction>(
    'Transactions',
    $TransactionsDoc.new,
    null,
    this,
  );
}

class $TransactionsDoc extends $Document<Transaction> {
  $TransactionsDoc(super.id, super.collection);

  // ignore: non_constant_identifier_names
  late final Id = $Collection<$IdDoc, StringData>('Id', $IdDoc.new, null, this);
}

class $IdDoc extends $Document<StringData> {
  $IdDoc(super.id, super.collection);
}
