import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Safe Firebase initialisation that never blocks offline startup.
///
/// The on-device AI pipeline (`llamadart` / GGUF) must keep working even when
/// Firebase is unavailable, misconfigured, or the device is offline. Any
/// failure here is logged and swallowed; the app continues in offline mode and
/// cloud AI simply stays disabled until Firebase is configured.
///
/// TODO(firebase): wire up real Firebase configuration before enabling cloud
/// AI (Gemini / Vertex AI via Firebase AI Logic):
///   1. Add `android/app/google-services.json` (and `GoogleService-Info.plist`
///      for iOS) from the Firebase console.
///   2. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
///   3. Apply the `com.google.gms.google-services` Gradle plugin and pass
///      `options: DefaultFirebaseOptions.currentPlatform` to
///      `Firebase.initializeApp` below.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<bool> initializeSafely() async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp();
      _initialized = true;
      return true;
    } catch (error, stackTrace) {
      _initialized = false;
      debugPrint(
        'Firebase initialization skipped/failed; continuing offline. '
        'Cloud AI stays disabled until Firebase is configured. '
        'Error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }
}
