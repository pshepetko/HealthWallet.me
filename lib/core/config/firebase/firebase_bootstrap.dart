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
///   1. Add `google-services.json` / `GoogleService-Info.plist` from the
///      Firebase console (Android is configured).
///   2. Run `flutterfire configure` to generate `lib/firebase_options.dart`
///      (generated).
///   3. Apply the `com.google.gms.google-services` Gradle plugin (applied) and
///      pass `optionsBuilder: () => DefaultFirebaseOptions.currentPlatform`.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Resolves [FirebaseOptions] lazily inside the guarded block so that platform
  /// configuration errors (e.g. unsupported platforms) also fall back to
  /// offline mode instead of crashing startup.
  static Future<bool> initializeSafely({
    FirebaseOptions Function()? optionsBuilder,
  }) async {
    if (_initialized) return true;
    try {
      await Firebase.initializeApp(
        options: optionsBuilder?.call(),
      );
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
