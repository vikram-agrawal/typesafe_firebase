import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

/// A centralized provider for managing Firebase service instances and configurations.
///
/// [FirebaseProvider] acts as a singleton-style factory that ensures Firebase
/// services like [FirebaseAuth] and [FirebaseFunctions] are initialized
/// correctly, supporting both production environments and local emulators.
class FirebaseProvider {
  static FirebaseApp? _firebaseApp;
  static String? _emulatorIp;
  static String? _region;
  static bool _setConfigCalled = false;

  // Configures the global settings for Firebase services.
  ///
  /// This must be called exactly once during the application initialization.
  /// It allows setting a specific [firebaseApp], a geographic [region] for
  /// Cloud Functions, and an [emulatorIp] for local development.
  ///
  /// Throws an [Exception] if called more than once to prevent configuration
  /// drifts during runtime.
  static void setConfig({
    FirebaseApp? firebaseApp,
    String? region,
    String? emulatorIp,
  }) {
    if (_setConfigCalled) {
      throw Exception("Config for FirebaseProvider can be set only once.");
    }
    _firebaseApp = firebaseApp;
    _emulatorIp = emulatorIp;
    _region = region;
    _setConfigCalled = true;
  }

  static FirebaseFunctions? _firebaseFunctionsInstance;

  /// Returns the configured [FirebaseFunctions] instance.
  ///
  /// The instance is lazily initialized using the [region] and [FirebaseApp]
  /// provided in [setConfig]. If an emulator IP was configured, it
  /// automatically points to the local Cloud Functions emulator on port 5001.
  static FirebaseFunctions get functions {
    if (_firebaseFunctionsInstance == null) {
      _firebaseFunctionsInstance = FirebaseFunctions.instanceFor(
        app: _firebaseApp,
        region: _region,
      );
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
  static FirebaseAuth get auth {
    if (_firebaseAuthInstance == null) {
      _firebaseAuthInstance = _firebaseApp == null
          ? FirebaseAuth.instance
          : FirebaseAuth.instanceFor(app: _firebaseApp!);
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
}
