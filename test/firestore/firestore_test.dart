import 'package:flutter_test/flutter_test.dart';

import 'schema.dart';

void main() {
  group('Firestore', () {
    test('Define schema', () async {
      (await UserClientStore().UserProfiles["a"].AuditTrails["1"].data).userId;
      (await UserClientStore()
              .Inventory["b"]
              .Packets["s"]
              .Transactions["e"]
              .data)
          .amt;
    });
  });
}
