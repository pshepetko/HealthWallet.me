import 'package:healthwithme/core/config/constants/shared_prefs_constants.dart';
import 'package:healthwithme/features/scan/data/services/ai_provider_resolver.dart';
import 'package:healthwithme/features/scan/data/services/local_ai_generation_service.dart';
import 'package:healthwithme/features/scan/data/services/vertex_ai_generation_service.dart';
import 'package:healthwithme/features/scan/domain/services/ai_generation_service.dart';
import 'package:healthwithme/features/scan/domain/services/scan_log_buffer.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Runs a generation request through the resolved provider and applies the
/// cloud → local fallback policy.
///
/// Cloud errors are never reported as a capacity/token-limit failure. If
/// `cloud_fallback_to_local` is enabled and the local model is usable, the
/// request is transparently retried on-device; otherwise a clear cloud error is
/// thrown.
@LazySingleton()
class AiGenerationCoordinator {
  AiGenerationCoordinator(
    this._resolver,
    this._localService,
    this._cloudService,
    this._prefs,
  );

  final AiProviderResolver _resolver;
  final LocalAiGenerationService _localService;
  final VertexAiGenerationService _cloudService;
  final SharedPreferences _prefs;

  String get _ts => DateTime.now().toIso8601String().substring(11, 23);

  bool get _cloudFallbackToLocal =>
      _prefs.getBool(SharedPrefsConstants.cloudFallbackToLocal) ?? true;

  /// Resolves the currently preferred provider (used by callers that need to
  /// know whether on-device-only preflight checks should run).
  Future<AiProviderSelection> resolveProvider() => _resolver.resolve();

  Future<String?> generateText({
    required String prompt,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) {
    return _execute(
      (service) => service.generateText(
        prompt: prompt,
        maxTokens: maxTokens,
        localOptions: localOptions,
      ),
    );
  }

  Future<String?> generateVision({
    required String prompt,
    required List<String> imagePaths,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) {
    return _execute(
      (service) => service.generateVision(
        prompt: prompt,
        imagePaths: imagePaths,
        maxTokens: maxTokens,
        localOptions: localOptions,
      ),
    );
  }

  Future<String?> generateVisionFromBytes({
    required String prompt,
    required List<AiImageBytes> images,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) {
    return _execute(
      (service) => service.generateVisionFromBytes(
        prompt: prompt,
        images: images,
        maxTokens: maxTokens,
        localOptions: localOptions,
      ),
    );
  }

  /// Releases on-device resources.
  Future<void> disposeLocal() => _localService.dispose();

  Future<String?> _execute(
    Future<String?> Function(AiGenerationService service) run,
  ) async {
    final selection = await _resolver.resolve();

    if (selection.isNone) {
      throw AiGenerationException(
        selection.reason.message,
        provider: AiProviderKind.none,
      );
    }

    if (selection.kind == AiProviderKind.onDevice) {
      return run(_localService);
    }

    try {
      return await run(_cloudService);
    } catch (e) {
      if (_cloudFallbackToLocal && await _localService.isAvailable()) {
        ScanLogBuffer.instance.log(
          '[$_ts][ScanAI] cloud generation failed, falling back to on-device: $e',
        );
        return run(_localService);
      }
      // Surface a clear cloud error; never as a capacity failure.
      final described = e is AiGenerationException ? e.message : e.toString();
      throw AiGenerationException(
        'Cloud AI failed and local fallback is unavailable: $described',
        provider: AiProviderKind.cloud,
        isCapacityFailure: false,
        cause: e,
      );
    }
  }
}
