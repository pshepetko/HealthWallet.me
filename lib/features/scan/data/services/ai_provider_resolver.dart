import 'package:firebase_core/firebase_core.dart';
import 'package:health_wallet/core/config/constants/shared_prefs_constants.dart';
import 'package:health_wallet/features/scan/data/services/local_ai_generation_service.dart';
import 'package:health_wallet/features/scan/data/services/vertex_ai_generation_service.dart';
import 'package:health_wallet/features/scan/domain/services/ai_generation_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Requested provider mode, stored under `ai_provider_mode`.
enum AiProviderMode { auto, onDevice, cloud }

/// Why the resolver picked the provider it did.
enum AiProviderSelectionReason {
  onDeviceReady,
  cloudReady,
  cloudConsentMissing,
  cloudFirebaseUnavailable,
  localModelUnavailable,
  noProviderAvailable,
}

extension AiProviderSelectionReasonMessage on AiProviderSelectionReason {
  String get message {
    switch (this) {
      case AiProviderSelectionReason.onDeviceReady:
        return 'Using the on-device AI model.';
      case AiProviderSelectionReason.cloudReady:
        return 'Using cloud AI.';
      case AiProviderSelectionReason.cloudConsentMissing:
        return 'Cloud AI requires explicit user consent for cloud processing '
            'of medical data.';
      case AiProviderSelectionReason.cloudFirebaseUnavailable:
        return 'Cloud AI is unavailable because Firebase is not initialized.';
      case AiProviderSelectionReason.localModelUnavailable:
        return 'The on-device AI model is not downloaded or the device cannot '
            'run it.';
      case AiProviderSelectionReason.noProviderAvailable:
        return 'No AI provider is available. Enable cloud AI or download the '
            'on-device model.';
    }
  }
}

/// Result of provider resolution.
class AiProviderSelection {
  const AiProviderSelection(this.kind, this.reason);

  final AiProviderKind kind;
  final AiProviderSelectionReason reason;

  bool get isNone => kind == AiProviderKind.none;

  @override
  String toString() => 'AiProviderSelection(${kind.name}, ${reason.name})';
}

/// Chooses the generation provider based on the user's mode, cloud consent,
/// Firebase state and local model availability.
@LazySingleton()
class AiProviderResolver {
  AiProviderResolver(
    this._localService,
    this._cloudService,
    this._prefs,
  );

  final LocalAiGenerationService _localService;
  final VertexAiGenerationService _cloudService;
  final SharedPreferences _prefs;

  AiProviderMode get _mode {
    final raw = _prefs.getString(SharedPrefsConstants.aiProviderMode);
    switch (raw) {
      case 'onDevice':
        return AiProviderMode.onDevice;
      case 'cloud':
        return AiProviderMode.cloud;
      case 'auto':
      default:
        return AiProviderMode.auto;
    }
  }

  bool get _cloudFallbackToLocal =>
      _prefs.getBool(SharedPrefsConstants.cloudFallbackToLocal) ?? true;

  /// Whether any provider can currently process documents (cloud with consent
  /// and Firebase, or a compatible on-device model). Provider-agnostic gate
  /// that replaces "is the GGUF file present?" checks.
  Future<bool> canProcessDocuments() async {
    final selection = await resolve();
    return selection.kind != AiProviderKind.none;
  }

  Future<AiProviderSelection> resolve() async {
    final mode = _mode;
    final localAvailable = await _localService.isAvailable();

    switch (mode) {
      case AiProviderMode.onDevice:
        return localAvailable
            ? const AiProviderSelection(
                AiProviderKind.onDevice,
                AiProviderSelectionReason.onDeviceReady,
              )
            : const AiProviderSelection(
                AiProviderKind.none,
                AiProviderSelectionReason.localModelUnavailable,
              );
      case AiProviderMode.cloud:
        final cloudSelection = await _resolveCloud();
        if (cloudSelection.kind == AiProviderKind.cloud) {
          return cloudSelection;
        }
        if (_cloudFallbackToLocal && localAvailable) {
          return const AiProviderSelection(
            AiProviderKind.onDevice,
            AiProviderSelectionReason.onDeviceReady,
          );
        }
        return cloudSelection;
      case AiProviderMode.auto:
        final cloudSelection = await _resolveCloud();
        if (cloudSelection.kind == AiProviderKind.cloud) {
          return cloudSelection;
        }
        if (localAvailable) {
          return const AiProviderSelection(
            AiProviderKind.onDevice,
            AiProviderSelectionReason.onDeviceReady,
          );
        }
        // No cloud and no local model: report the most actionable reason.
        if (cloudSelection.reason ==
            AiProviderSelectionReason.cloudConsentMissing) {
          return cloudSelection;
        }
        return const AiProviderSelection(
          AiProviderKind.none,
          AiProviderSelectionReason.noProviderAvailable,
        );
    }
  }

  Future<AiProviderSelection> _resolveCloud() async {
    final consent =
        _prefs.getBool(SharedPrefsConstants.cloudAiConsentGiven) ?? false;
    if (!consent) {
      return const AiProviderSelection(
        AiProviderKind.none,
        AiProviderSelectionReason.cloudConsentMissing,
      );
    }
    if (Firebase.apps.isEmpty) {
      return const AiProviderSelection(
        AiProviderKind.none,
        AiProviderSelectionReason.cloudFirebaseUnavailable,
      );
    }
    final available = await _cloudService.isAvailable();
    if (!available) {
      return const AiProviderSelection(
        AiProviderKind.none,
        AiProviderSelectionReason.cloudFirebaseUnavailable,
      );
    }
    return const AiProviderSelection(
      AiProviderKind.cloud,
      AiProviderSelectionReason.cloudReady,
    );
  }
}
