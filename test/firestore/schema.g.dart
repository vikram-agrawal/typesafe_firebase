// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

class UserClientStore {
  // ignore: non_constant_identifier_names
  final UserProfiles = $Collection<$UserProfilesDoc>($UserProfilesDoc.new);

  // ignore: non_constant_identifier_names
  final Inventory = $Collection<$InventoryDoc>($InventoryDoc.new);
}

class $UserProfilesDoc extends $Document<UserProfile> {
  // ignore: non_constant_identifier_names
  final AuditTrails = $Collection<$AuditTrailsDoc>($AuditTrailsDoc.new);
}

class $AuditTrailsDoc extends $Document<UserProfile> {}

class $InventoryDoc extends $Document<InventoryItem> {
  // ignore: non_constant_identifier_names
  final Packets = $Collection<$PacketsDoc>($PacketsDoc.new);
}

class $PacketsDoc extends $Document<Packet> {
  // ignore: non_constant_identifier_names
  final Transactions = $Collection<$TransactionsDoc>($TransactionsDoc.new);
}

class $TransactionsDoc extends $Document<Transaction> {
  // ignore: non_constant_identifier_names
  final Id = $Collection<$IdDoc>($IdDoc.new);
}

class $IdDoc extends $Document<StringData> {}
