// GENERATED CODE - DO NOT MODIFY
import "package:typesafe_firebase/typesafe_firebase.dart";
import "models.dart";

void registerAllModels() {
  BaseModel.register<UserProfile>(
    toJson: UserProfileToJson,
    fromJson: UserProfileFromJson,
  );
  BaseModel.register<InventoryItem>(
    toJson: InventoryItemToJson,
    fromJson: InventoryItemFromJson,
  );
  BaseModel.register<Packet>(
    toJson: PacketToJson,
    fromJson: PacketFromJson,
  );
  BaseModel.register<Transaction>(
    toJson: TransactionToJson,
    fromJson: TransactionFromJson,
  );
}
