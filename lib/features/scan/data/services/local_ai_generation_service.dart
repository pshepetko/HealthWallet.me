import 'dart:io';

import 'package:health_wallet/core/config/constants/shared_prefs_constants.dart';
import 'package:health_wallet/features/scan/data/data_source/network/scan_network_data_source.dart';
import 'package:health_wallet/features/scan/domain/services/ai_generation_service.dart';
import 'package:health_wallet/features/scan/domain/services/scan_log_buffer.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device generation adapter backed by the existing `llamadart` /
/// `ScanNetworkDataSource` pipeline.
///
/// It keeps the local parameters (`contextSize`, `gpuLayers`, `threads`,
/// `mmproj`) and the memory/device checks intact. No behaviour of the local
/// engine is changed; this is only a thin, provider-agnostic wrapper.
@LazySingleton()
class LocalAiGenerationService implements AiGenerationService {
  LocalAiGenerationService(this._networkDataSource, this._prefs);

  final ScanNetworkDataSource _networkDataSource;
  final SharedPreferences _prefs;

  bool? _loadedWithVision;

  static const int _minTextContextSize = 2048;

  @override
  AiProviderKind get kind => AiProviderKind.onDevice;

  String get _ts => DateTime.now().toIso8601String().substring(11, 23);

  @override
  Future<bool> isAvailable() async {
    try {
      final hasModel = await _networkDataSource.checkModelExistence();
      if (!hasModel) return false;

      // Device capability / memory compatibility, reusing the existing service.
      final health = await _networkDataSource.checkMemoryHealth();
      if (!health.canProceed) {
        ScanLogBuffer.instance.log(
          '[$_ts][ScanAI] local AI unavailable: ${health.availableMB}MB '
          '< required ${health.requiredMB}MB',
        );
        return false;
      }
      return true;
    } catch (e) {
      ScanLogBuffer.instance
          .log('[$_ts][ScanAI] local AI availability check failed: $e');
      return false;
    }
  }

  Future<void> _ensureModel({
    required bool withVision,
    AiLocalGenerationOptions? localOptions,
  }) async {
    if (_loadedWithVision == withVision) return;

    if (_loadedWithVision != null) {
      await _networkDataSource.disposeModel();
      _loadedWithVision = null;
    }

    final savedContextSize = localOptions?.contextSize ??
        _prefs.getInt(SharedPrefsConstants.aiContextSize);
    final savedGpuLayers = localOptions?.gpuLayers ??
        _prefs.getInt(SharedPrefsConstants.aiGpuLayers);
    final savedThreads =
        localOptions?.threads ?? _prefs.getInt(SharedPrefsConstants.aiThreads);

    final contextSize = withVision
        ? savedContextSize
        : (savedContextSize == null || savedContextSize < _minTextContextSize
            ? _minTextContextSize
            : savedContextSize);

    await _networkDataSource.initModel(
      withVision: withVision,
      contextSize: contextSize,
      gpuLayers: withVision ? savedGpuLayers : null,
      threads: savedThreads,
    );
    _loadedWithVision = withVision;
  }

  int? _resolveMaxTokens(int? maxTokens) =>
      maxTokens ?? _prefs.getInt(SharedPrefsConstants.aiMaxTokens);

  @override
  Future<String?> generateText({
    required String prompt,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    await _ensureModel(withVision: false, localOptions: localOptions);
    return _networkDataSource.runTextPrompt(
      prompt: prompt,
      maxTokens: _resolveMaxTokens(maxTokens),
    );
  }

  @override
  Future<String?> generateVision({
    required String prompt,
    required List<String> imagePaths,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    await _ensureModel(withVision: true, localOptions: localOptions);
    return _networkDataSource.runVisionPrompt(
      prompt: prompt,
      imagePaths: imagePaths,
      maxTokens: _resolveMaxTokens(maxTokens),
    );
  }

  @override
  Future<String?> generateVisionFromBytes({
    required String prompt,
    required List<AiImageBytes> images,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    // The on-device engine works with file paths, so materialise bytes into
    // temporary files and clean them up afterwards.
    final dir = await getTemporaryDirectory();
    final tempPaths = <String>[];
    try {
      for (var i = 0; i < images.length; i++) {
        final ext = _extensionForMime(images[i].mimeType);
        final file = File(path.join(
          dir.path,
          'ai_vision_${DateTime.now().microsecondsSinceEpoch}_$i$ext',
        ));
        await file.writeAsBytes(images[i].bytes, flush: true);
        tempPaths.add(file.path);
      }
      return await generateVision(
        prompt: prompt,
        imagePaths: tempPaths,
        maxTokens: maxTokens,
        localOptions: localOptions,
      );
    } finally {
      for (final tempPath in tempPaths) {
        try {
          final file = File(tempPath);
          if (await file.exists()) await file.delete();
        } catch (_) {}
      }
    }
  }

  String _extensionForMime(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/heic':
      case 'image/heif':
        return '.heic';
      case 'image/jpeg':
      case 'image/jpg':
      default:
        return '.jpg';
    }
  }

  @override
  Future<void> dispose() async {
    await _networkDataSource.disposeModel();
    _loadedWithVision = null;
  }
}
