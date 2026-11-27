import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthwithme/core/config/constants/shared_prefs_constants.dart';
import 'package:healthwithme/features/scan/domain/services/ai_generation_service.dart';
import 'package:healthwithme/features/scan/domain/services/scan_log_buffer.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Cloud generation adapter backed by Firebase AI Logic (Vertex AI / Gemini).
///
/// NOTE: in firebase_ai >= 5.x the previous `FirebaseAI.vertexAI()` factory was
/// renamed to `FirebaseAI.agentPlatform()` (the Vertex AI backend). It is used
/// here with an explicit comment so the intent stays clear.
///
/// The returned raw text/JSON is handed straight back to the existing FHIR
/// parser. Cloud failures are surfaced as [AiGenerationException] with
/// `isCapacityFailure == false` so they are never mistaken for a local
/// context/token capacity issue.
@LazySingleton()
class VertexAiGenerationService implements AiGenerationService {
  VertexAiGenerationService(this._prefs);

  final SharedPreferences _prefs;

  static const String defaultModelName = 'gemini-2.5-flash';

  static const String _systemInstruction =
      'You are a medical document data extractor. Output only valid JSON.';

  @override
  AiProviderKind get kind => AiProviderKind.cloud;

  String get _ts => DateTime.now().toIso8601String().substring(11, 23);

  String get modelName {
    final configured =
        _prefs.getString(SharedPrefsConstants.cloudAiModelName)?.trim();
    if (configured == null || configured.isEmpty) return defaultModelName;
    return configured;
  }

  bool get _hasConsent =>
      _prefs.getBool(SharedPrefsConstants.cloudAiConsentGiven) ?? false;

  @override
  Future<bool> isAvailable() async {
    if (!_hasConsent) return false;
    return Firebase.apps.isNotEmpty;
  }

  GenerativeModel _model({int? maxTokens}) {
    // FirebaseAI.agentPlatform() == the former FirebaseAI.vertexAI() (Vertex AI).
    final ai = FirebaseAI.agentPlatform();
    return ai.generativeModel(
      model: modelName,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        maxOutputTokens: maxTokens,
        temperature: 0.0,
        topK: 1,
        topP: 1.0,
      ),
    );
  }

  @override
  Future<String?> generateText({
    required String prompt,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    try {
      final response = await _model(maxTokens: maxTokens)
          .generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      throw _asCloudFailure(e);
    }
  }

  @override
  Future<String?> generateVision({
    required String prompt,
    required List<String> imagePaths,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    try {
      final images = <AiImageBytes>[];
      for (final imagePath in imagePaths) {
        final bytes = await File(imagePath).readAsBytes();
        images.add(AiImageBytes(
          bytes: bytes,
          mimeType: _mimeTypeForPath(imagePath),
        ));
      }
      return await generateVisionFromBytes(
        prompt: prompt,
        images: images,
        maxTokens: maxTokens,
        localOptions: localOptions,
      );
    } on AiGenerationException {
      rethrow;
    } catch (e) {
      throw _asCloudFailure(e);
    }
  }

  @override
  Future<String?> generateVisionFromBytes({
    required String prompt,
    required List<AiImageBytes> images,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  }) async {
    try {
      final parts = <Part>[
        for (final image in images)
          InlineDataPart(image.mimeType, image.bytes),
        TextPart(prompt),
      ];
      final response =
          await _model(maxTokens: maxTokens).generateContent([
        Content.multi(parts),
      ]);
      return response.text;
    } catch (e) {
      throw _asCloudFailure(e);
    }
  }

  AiGenerationException _asCloudFailure(Object error) {
    final described = error is AiGenerationException
        ? error.message
        : error.toString();
    ScanLogBuffer.instance.log('[$_ts][ScanAI] cloud generation failed: $described');
    return AiGenerationException(
      'Cloud AI request failed: $described',
      provider: AiProviderKind.cloud,
      // Never mask cloud errors as a local capacity/token-limit failure.
      isCapacityFailure: false,
      cause: error,
    );
  }

  String _mimeTypeForPath(String imagePath) {
    final ext = path.extension(imagePath).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
      case '.heif':
        return 'image/heic';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }

  @override
  Future<void> dispose() async {
    // Cloud model handles are stateless; nothing to release.
  }
}
