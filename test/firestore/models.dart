import 'package:typesafe_firebase/typesafe_firebase.dart';

part 'models.g.dart';

@Model()
class UserProfile extends BaseModel {
  String userId = '0';
}

@Model()
class InventoryItem extends BaseModel {
  int itemId = 0;
}

@Model()
class Packet extends BaseModel {
  int id = 0;
  int qty = 0;
}

@Model()
class Transaction extends BaseModel {
  int id = 0;
  double amt = 0;
}
