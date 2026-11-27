import 'dart:typed_data';

/// Which backend is responsible for a generation request.
enum AiProviderKind { onDevice, cloud, none }

/// On-device generation parameters.
///
/// These are only meaningful for the on-device provider; cloud providers ignore
/// them. Passing them through the coordinator keeps RAM/context tuning out of
/// the cloud code path.
class AiLocalGenerationOptions {
  const AiLocalGenerationOptions({
    this.contextSize,
    this.gpuLayers,
    this.threads,
  });

  final int? contextSize;
  final int? gpuLayers;
  final int? threads;
}

/// Raw image bytes plus mime type, provider-agnostic.
///
/// Deliberately independent of any on-device (GGUF) or cloud (Gemini) types so
/// callers can pass images without leaking storage or SDK details.
class AiImageBytes {
  const AiImageBytes({
    required this.bytes,
    this.mimeType = 'image/jpeg',
  });

  final Uint8List bytes;
  final String mimeType;
}

/// A provider-agnostic failure raised by an [AiGenerationService].
///
/// [isCapacityFailure] is only ever set for genuine context/token limits of the
/// on-device model. Cloud failures (network, timeout, quota, service errors)
/// must remain `false` so they are not misreported as a context capacity issue.
class AiGenerationException implements Exception {
  const AiGenerationException(
    this.message, {
    this.provider = AiProviderKind.none,
    this.isCapacityFailure = false,
    this.cause,
  });

  final String message;
  final AiProviderKind provider;
  final bool isCapacityFailure;
  final Object? cause;

  @override
  String toString() => message;
}

/// Abstraction over text and vision generation.
///
/// Implementations must not expose GGUF, model file paths or any specific SDK
/// objects. Both adapters return raw model text so the existing FHIR/JSON
/// parser can process the response unchanged.
abstract class AiGenerationService {
  /// Which provider this service represents.
  AiProviderKind get kind;

  /// Whether this provider can currently serve a request (consent, Firebase
  /// readiness, local model presence, device memory, ...).
  Future<bool> isAvailable();

  /// Generates text from [prompt].
  Future<String?> generateText({
    required String prompt,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  });

  /// Generates from a [prompt] plus images given as local file paths.
  Future<String?> generateVision({
    required String prompt,
    required List<String> imagePaths,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  });

  /// Generates from a [prompt] plus in-memory image bytes (no file paths).
  Future<String?> generateVisionFromBytes({
    required String prompt,
    required List<AiImageBytes> images,
    int? maxTokens,
    AiLocalGenerationOptions? localOptions,
  });

  /// Releases any held resources (e.g. a loaded on-device model).
  Future<void> dispose();
}
