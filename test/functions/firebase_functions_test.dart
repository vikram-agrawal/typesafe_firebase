import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:typesafe_firebase/firebase/firebase_provider.dart';
import 'package:typesafe_firebase/models/common_models.dart';
import 'package:typesafe_firebase/functions/firebase_functions.dart';
import 'package:typesafe_firebase/models/register_models.dart';
import 'package:mockito/annotations.dart';

import '../mocks/functions/firebase_functions_test.mocks.dart';

class TestFirebaseApiService extends FirebaseFunctionsService {
  TestFirebaseApiService() : super(prefix: '/user');

  late final loadUser = createFunction<IntData, StringData>("/load");

  late final saveUser = createFunction<StringData, IntData>(
    "/save",
    isAuthenticated: true,
  );
}

@GenerateNiceMocks([
  MockSpec<User>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFunctions>(),
  MockSpec<HttpsCallable>(),
  MockSpec<HttpsCallableResult>(),
])
void main() {
  group('FirebaseFunctions', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFunctions mockFunctions;
    late MockHttpsCallable mockCallable;
    late TestFirebaseApiService service;

    setUpAll(() {
      registerCommonModels();
    });

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFunctions = MockFirebaseFunctions();
      mockCallable = MockHttpsCallable();
      FirebaseProvider.functionsForTesting = mockFunctions;
      FirebaseProvider.authForTesting = mockAuth;

      service = TestFirebaseApiService();
    });

    test('Call to firebase function should succeed.', () async {
      final mockResult = MockHttpsCallableResult();

      when(
        mockFunctions.httpsCallable(any),
      ).thenThrow(Exception("Function mock not set correctly."));
      when(mockFunctions.httpsCallable('/user/load')).thenReturn(mockCallable);

      when(
        mockCallable.call(any),
      ).thenThrow(Exception("Callable mock not set correctly."));
      when(mockCallable.call({'Value': 5})).thenAnswer((_) async => mockResult);

      when(mockResult.data).thenReturn(<String, dynamic>{'Value': 'User1'});

      StringData output = await service.loadUser(IntData(5));

      expect(output.value, 'User1');
    });

    test(
      'Call to authenticated firebase function without auth should fail.',
      () async {
        when(
          mockFunctions.httpsCallable(any),
        ).thenThrow(Exception("Function mock not set correctly."));

        when(
          mockCallable.call(any),
        ).thenThrow(Exception("Callable mock not set correctly."));

        await expectLater(
          service.saveUser(StringData("User2")),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Authentication required'),
            ),
          ),
        );
      },
    );

    test(
      'Call to authenticated firebase function with auth should succeed.',
      () async {
        final mockResult = MockHttpsCallableResult();
        when(
          mockFunctions.httpsCallable(any),
        ).thenThrow(Exception("Function mock not set correctly."));
        when(
          mockFunctions.httpsCallable('/user/save'),
        ).thenReturn(mockCallable);

        when(
          mockCallable.call(any),
        ).thenThrow(Exception("Callable mock not set correctly."));
        when(
          mockCallable.call({'Value': 'User2'}),
        ).thenAnswer((_) async => mockResult);

        when(mockResult.data).thenReturn(<String, dynamic>{'Value': 7});

        when(mockAuth.currentUser).thenReturn(MockUser());
        IntData result = await service.saveUser(StringData("User2"));
        expect(result.value, 7);
      },
    );
  });
}
