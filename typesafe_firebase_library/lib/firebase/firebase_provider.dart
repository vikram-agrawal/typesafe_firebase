import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

/// A centralized provider for managing Firebase service instances and configurations.
///
/// [FirebaseProvider] acts as a singleton-style factory that ensures Firebase
/// services like [FirebaseAuth], [FirebaseFunctions], [Firestore] are initialized
/// correctly, supporting both production environments and local emulators.
class FirebaseProvider {
  static FirebaseApp? _firebaseAppInstance;
  static String? _emulatorIp;
  static bool _setConfigCalled = false;

  // Configures the global settings for Firebase services.
  ///
  /// This must be called exactly once during the application initialization.
  /// It allows setting a specific [firebaseApp], and an [emulatorIp] for local development.
  ///
  /// Throws an [Exception] if called more than once to prevent configuration
  /// drifts during runtime.
  static void setConfig({FirebaseApp? firebaseApp, String? emulatorIp}) {
    if (_setConfigCalled) {
      throw Exception("Config for FirebaseProvider can be set only once.");
    }
    _firebaseAppInstance = firebaseApp;
    _emulatorIp = emulatorIp;
    _setConfigCalled = true;
  }

  static FirebaseApp get _firebaseApp {
    return _firebaseAppInstance ?? Firebase.app();
  }

  static FirebaseFunctions? _firebaseFunctionsInstance;

  /// Returns the configured [FirebaseFunctions] instance.
  ///
  /// The instance is lazily initialized using the [region] and [FirebaseApp]
  /// provided in [setConfig]. If an emulator IP was configured, it
  /// automatically points to the local Cloud Functions emulator on port 5001.
  static FirebaseFunctions functions(String? region) {
    if (_firebaseFunctionsInstance == null) {
      _firebaseFunctionsInstance =
          _firebaseAppInstance == null && region == null
          ? FirebaseFunctions.instance
          : FirebaseFunctions.instanceFor(app: _firebaseApp, region: region);
      if (_emulatorIp != null && _emulatorIp!.isNotEmpty) {
        _firebaseFunctionsInstance!.useFunctionsEmulator(_emulatorIp!, 5001);
      }
    }
    return _firebaseFunctionsInstance!;
  }

  @visibleForTesting
  static set functionsForTesting(FirebaseFunctions instance) {
    _firebaseFunctionsInstance = instance;
  }

  static FirebaseAuth? _firebaseAuthInstance;

  /// Returns the configured [FirebaseAuth] instance.
  ///
  /// The instance is lazily initialized. If an [emulatorIp] was provided in
  /// [setConfig], the instance will be configured to use the local
  /// Authentication emulator on port 9099
  static FirebaseAuth auth() {
    if (_firebaseAuthInstance == null) {
      _firebaseAuthInstance = _firebaseAppInstance == null
          ? FirebaseAuth.instance
          : FirebaseAuth.instanceFor(app: _firebaseApp);
      if (_emulatorIp != null && _emulatorIp!.isNotEmpty) {
        _firebaseAuthInstance!.useAuthEmulator(_emulatorIp!, 9099);
      }
    }
    return _firebaseAuthInstance!;
  }

  @visibleForTesting
  static set authForTesting(FirebaseAuth instance) {
    _firebaseAuthInstance = instance;
  }

  static FirebaseFirestore? _firestoreInstance;

  static FirebaseFirestore firestore({String? databaseId}) {
    if (_firestoreInstance == null) {
      _firestoreInstance = (_firebaseAppInstance == null && databaseId == null)
          ? FirebaseFirestore.instance
          : FirebaseFirestore.instanceFor(
              app: _firebaseApp,
              databaseId: databaseId,
            );
      if (_emulatorIp != null && _emulatorIp!.isNotEmpty) {
        _firestoreInstance!.useFirestoreEmulator(_emulatorIp!, 8080);
      }
    }

    return _firestoreInstance!;
  }
}
