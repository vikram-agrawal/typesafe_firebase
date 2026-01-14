import 'package:flutter_test/flutter_test.dart';

import 'schema.dart';

void main() {
  group('Firestore', () {
    test('Define schema', () async {
      if (await UserClientStore().UserProfiles["a"].AuditTrails["1"].exists) {
        var _ =
            (await UserClientStore().UserProfiles["a"].AuditTrails["1"].data)
                .userId;
      }

      var _ =
          (await UserClientStore()
                  .Inventory["b"]
                  .Packets["s"]
                  .Transactions["e"]
                  .data)
              .amt;
    });
  });
}
