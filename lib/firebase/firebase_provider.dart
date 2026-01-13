import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class FirebaseProvider {
  static FirebaseApp? _firebaseApp;
  static String? _emulatorIp;
  static String? _region;
  static bool _setConfigCalled = false;

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
