// GENERATED CODE - DO NOT MODIFY
import "package:typesafe_firebase/models.dart";
import "package:typesafe_firebase_examples/functions/models.dart";

void registerAllModels() {
  registerCommonModels();

  BaseModel.register<UserProfile>(
    toJson: UserProfileToJson,
    fromJson: UserProfileFromJson,
  );
}
