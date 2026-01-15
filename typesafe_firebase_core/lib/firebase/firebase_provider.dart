import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';

/// A centralized provider for managing Firebase service instances and configurations.
///
/// [FirebaseProvider] acts as a singleton-style factory that ensures Firebase
/// services like [FirebaseAuth], [FirebaseFunctions], and [FirebaseFirestore]
/// are initialized correctly, supporting both production environments and local emulators.
class FirebaseProvider {
  /// The specific [FirebaseApp] instance to use, if any.
  static FirebaseApp? _firebaseAppInstance;

  /// The IP address used for connecting to local Firebase emulators.
  static String? _emulatorIp;

  /// Internal flag to ensure [setConfig] is only executed once.
  static bool _setConfigCalled = false;

  /// Configures the global settings for Firebase services.
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

  /// Returns the provided [FirebaseApp] or the default app instance.
  static FirebaseApp get _firebaseApp {
    return _firebaseAppInstance ?? Firebase.app();
  }

  /// Internal cached instance of [FirebaseFunctions].
  static FirebaseFunctions? _firebaseFunctionsInstance;

  /// Returns the configured [FirebaseFunctions] instance.
  ///
  /// The instance is lazily initialized using the [region] and [FirebaseApp]
  /// provided in [setConfig]. If an emulator IP was configured, it
  /// automatically points to the local Cloud Functions emulator on port 5001.
  static FirebaseFunctions functions(String? region) {
    if (_firebaseFunctionsInstance == null) {
      _firebaseFunctionsInstance = _firebaseAppInstance == null && region == null
          ? FirebaseFunctions.instance
          : FirebaseFunctions.instanceFor(app: _firebaseApp, region: region);
      if (_emulatorIp != null && _emulatorIp!.isNotEmpty) {
        _firebaseFunctionsInstance!.useFunctionsEmulator(_emulatorIp!, 5001);
      }
    }
    return _firebaseFunctionsInstance!;
  }

  /// Allows injecting a mock [FirebaseFunctions] instance for testing.
  @visibleForTesting
  static set functionsForTesting(FirebaseFunctions instance) {
    _firebaseFunctionsInstance = instance;
  }

  /// Internal cached instance of [FirebaseAuth].
  static FirebaseAuth? _firebaseAuthInstance;

  /// Returns the configured [FirebaseAuth] instance.
  ///
  /// The instance is lazily initialized. If an [emulatorIp] was provided in
  /// [setConfig], the instance will be configured to use the local
  /// Authentication emulator on port 9099.
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

  /// Allows injecting a mock [FirebaseAuth] instance for testing.
  @visibleForTesting
  static set authForTesting(FirebaseAuth instance) {
    _firebaseAuthInstance = instance;
  }

  /// Internal cached instance of [FirebaseFirestore].
  static FirebaseFirestore? _firestoreInstance;

  /// Returns the configured [FirebaseFirestore] instance.
  ///
  /// The instance is lazily initialized using the [databaseId] (if provided)
  /// and the [FirebaseApp] configured in [setConfig].
  ///
  /// If an [emulatorIp] was provided in [setConfig], the instance will be
  /// configured to use the local Firestore emulator on port 8080.
  static FirebaseFirestore firestore({String? databaseId}) {
    if (_firestoreInstance == null) {
      _firestoreInstance = (_firebaseAppInstance == null && databaseId == null)
          ? FirebaseFirestore.instance
          : FirebaseFirestore.instanceFor(app: _firebaseApp, databaseId: databaseId);
      if (_emulatorIp != null && _emulatorIp!.isNotEmpty) {
        _firestoreInstance!.useFirestoreEmulator(_emulatorIp!, 8080);
      }
    }

    return _firestoreInstance!;
  }
}
