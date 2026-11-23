import 'dart:convert';

import 'package:health_wallet/core/utils/logger.dart';
import 'package:health_wallet/features/records/domain/entity/patient/patient.dart';
import 'package:health_wallet/features/sync/data/data_source/local/sync_local_data_source.dart';
import 'package:health_wallet/features/sync/data/dto/fhir_resource_dto.dart';
import 'package:health_wallet/features/sync/domain/entities/source.dart';
import 'package:health_wallet/features/sync/domain/services/demo_data_extractor.dart';
import 'package:uuid/uuid.dart';

/// Thrown when an imported file cannot be parsed or validated.
class FhirFileImportException implements Exception {
  const FhirFileImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FhirFileImportResult {
  const FhirFileImportResult({
    required this.importedCount,
    required this.skippedPatients,
    required this.sourceId,
    required this.patientId,
    required this.patientName,
  });

  final int importedCount;
  final int skippedPatients;
  final String sourceId;
  final String patientId;
  final String patientName;
}

/// Imports FHIR resources from a local JSON file into the Drift
/// `fhir_resource` table using [SyncLocalDataSource.cacheFhirResources].
///
/// Supported payloads:
/// * a FHIR Bundle: `{ "resourceType": "Bundle", "entry": [...] }`
/// * `{ "resources": [...] }`
/// * a single FHIR resource: `{ "resourceType": "Observation", ... }`
/// * a top-level JSON array of FHIR resources
class FhirFileImportService {
  FhirFileImportService(this._localDataSource);

  final SyncLocalDataSource _localDataSource;

  static const int _maxFileResources = 5000;

  /// FHIR resource types whose `subject` reference is bound to the selected
  /// patient. Resources that already contain `subject` are also rebound.
  static const Set<String> _subjectResourceTypes = {
    'AdverseEvent',
    'AllergyIntolerance',
    'CareTeam',
    'Condition',
    'DiagnosticReport',
    'DocumentReference',
    'Encounter',
    'FamilyMemberHistory',
    'Goal',
    'Immunization',
    'Media',
    'MedicationAdministration',
    'MedicationDispense',
    'MedicationRequest',
    'MedicationStatement',
    'Observation',
    'Procedure',
    'QuestionnaireResponse',
    'RiskAssessment',
    'ServiceRequest',
    'Specimen',
  };

  Future<FhirFileImportResult> importJsonFile({
    required String jsonContent,
    required String fileName,
    required Patient patient,
  }) async {
    final parsedResources = _parseResources(jsonContent);

    if (parsedResources.length > _maxFileResources) {
      throw const FhirFileImportException(
        'The selected file contains too many resources. '
        'Please split it into smaller files.',
      );
    }

    final now = DateTime.now();
    final batchToken = now.microsecondsSinceEpoch.toString();
    final sourceId = 'import-${_sanitize(patient.id)}-$batchToken';
    final subjectId = patient.resourceId.isNotEmpty
        ? patient.resourceId
        : patient.id;

    final idMap = <String, String>{};
    final patientOriginalIds = <String>{};
    final pending = <({Map<String, dynamic> resource, String newId})>[];
    var skippedPatients = 0;

    for (var i = 0; i < parsedResources.length; i++) {
      final resource = parsedResources[i];
      final resourceType = resource['resourceType'] as String;
      final originalId = resource['id'] is String
          ? (resource['id'] as String).trim()
          : '';

      if (originalId.isNotEmpty) {
        if (idMap.containsKey(originalId)) {
          throw FhirFileImportException(
            'The file contains duplicate resource id "$originalId". '
            'Resource ids must be unique inside the imported bundle.',
          );
        }
      }

      if (resourceType == 'Patient') {
        skippedPatients++;
        if (originalId.isNotEmpty) {
          // References to a Patient coming from the file are redirected to the
          // patient selected by the user.
          idMap[originalId] = subjectId;
          patientOriginalIds.add(originalId);
        }
        continue;
      }

      final String newId;
      if (originalId.isNotEmpty) {
        newId = '${sourceId}_${_sanitize(originalId)}';
      } else {
        newId = '${sourceId}_${const Uuid().v4()}';
      }

      if (originalId.isNotEmpty) {
        idMap[originalId] = newId;
      }

      pending.add((resource: resource, newId: newId));
    }

    if (pending.isEmpty) {
      throw const FhirFileImportException(
        'The selected file does not contain importable clinical resources. '
        'It only contains Patient resources.',
      );
    }

    final dtos = pending.map((item) {
      final prepared = _prepareResource(
        resource: item.resource,
        newId: item.newId,
        subjectId: subjectId,
        idMap: idMap,
        patientOriginalIds: patientOriginalIds,
      );

      return FhirResourceDto(
        id: item.newId,
        sourceId: sourceId,
        resourceType: prepared['resourceType'] as String,
        resourceId: item.newId,
        title: DemoDataExtractor.extractTitle(prepared),
        date: DemoDataExtractor.extractDate(prepared),
        resourceRaw: prepared,
        changeType: 'created',
      ).populateEncounterIdFromRaw().populateSubjectIdFromRaw();
    }).toList();

    await _localDataSource.cacheSources([
      Source(
        id: sourceId,
        platformName: 'wallet',
        labelSource: _sourceLabel(fileName),
        platformType: 'wallet',
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    await _localDataSource.cacheFhirResources(dtos);

    logger.i(
      'Imported ${dtos.length} FHIR resources from "$fileName" '
      'into source "$sourceId" for patient ${patient.id}',
    );

    return FhirFileImportResult(
      importedCount: dtos.length,
      skippedPatients: skippedPatients,
      sourceId: sourceId,
      patientId: patient.id,
      patientName: patient.displayTitle,
    );
  }

  List<Map<String, dynamic>> _parseResources(String content) {
    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (e) {
      throw FhirFileImportException(
        'The selected file is not valid JSON: ${e.message}',
      );
    } catch (e) {
      throw FhirFileImportException(
        'The selected file could not be read as JSON: $e',
      );
    }

    final resources = <Map<String, dynamic>>[];

    void addResource(dynamic value, String location) {
      if (value is! Map) {
        throw FhirFileImportException(
          '$location is not a valid FHIR resource object.',
        );
      }

      final map = Map<String, dynamic>.from(value);
      final resourceType = map['resourceType'];
      if (resourceType is! String || resourceType.trim().isEmpty) {
        throw FhirFileImportException(
          '$location is missing a valid "resourceType".',
        );
      }

      resources.add(map);
    }

    if (decoded is List) {
      for (var i = 0; i < decoded.length; i++) {
        addResource(decoded[i], 'Resource at index $i');
      }
    } else if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final entries = map['entry'];
      final resourceList = map['resources'];

      if (entries is List) {
        if (entries.isEmpty) {
          throw const FhirFileImportException(
            'The FHIR Bundle does not contain any entries.',
          );
        }
        for (var i = 0; i < entries.length; i++) {
          final entry = entries[i];
          if (entry is Map && entry['resource'] != null) {
            addResource(entry['resource'], 'Bundle entry $i');
          } else {
            addResource(entry, 'Bundle entry $i');
          }
        }
      } else if (resourceList is List) {
        if (resourceList.isEmpty) {
          throw const FhirFileImportException(
            'The "resources" array in the selected file is empty.',
          );
        }
        for (var i = 0; i < resourceList.length; i++) {
          addResource(resourceList[i], 'Resource at index $i');
        }
      } else if (map['resourceType'] is String) {
        addResource(map, 'Resource');
      } else {
        throw const FhirFileImportException(
          'Unsupported JSON structure. Expected a FHIR Bundle '
          '("entry" array), a "resources" array, or a single FHIR resource.',
        );
      }
    } else {
      throw const FhirFileImportException(
        'Unsupported JSON structure. Expected a JSON object or array.',
      );
    }

    if (resources.isEmpty) {
      throw const FhirFileImportException(
        'The selected file does not contain any FHIR resources.',
      );
    }

    return resources;
  }

  Map<String, dynamic> _prepareResource({
    required Map<String, dynamic> resource,
    required String newId,
    required String subjectId,
    required Map<String, String> idMap,
    required Set<String> patientOriginalIds,
  }) {
    final prepared = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(resource)) as Map,
    );

    prepared['id'] = newId;
    _rewriteReferences(prepared, idMap, patientOriginalIds);

    final resourceType = prepared['resourceType'] as String;
    if (_subjectResourceTypes.contains(resourceType) ||
        prepared.containsKey('subject')) {
      prepared['subject'] = {'reference': 'Patient/$subjectId'};
    }

    return prepared;
  }

  void _rewriteReferences(
    dynamic node,
    Map<String, String> idMap,
    Set<String> patientOriginalIds,
  ) {
    if (node is Map) {
      for (final key in node.keys.toList(growable: false)) {
        final value = node[key];
        if (key == 'reference' && value is String) {
          final rewritten = _rewriteReferenceString(
            value,
            idMap,
            patientOriginalIds,
          );
          if (rewritten != null) {
            node[key] = rewritten;
          }
        } else if (value is Map || value is List) {
          _rewriteReferences(value, idMap, patientOriginalIds);
        }
      }
    } else if (node is List) {
      for (final value in node) {
        if (value is Map || value is List) {
          _rewriteReferences(value, idMap, patientOriginalIds);
        }
      }
    }
  }

  String? _rewriteReferenceString(
    String reference,
    Map<String, String> idMap,
    Set<String> patientOriginalIds,
  ) {
    final trimmed = reference.trim();

    if (trimmed.startsWith('urn:uuid:')) {
      final originalId = trimmed.substring('urn:uuid:'.length);
      final newId = idMap[originalId];
      if (newId == null) return null;
      if (patientOriginalIds.contains(originalId)) {
        return 'Patient/$newId';
      }
      return 'urn:uuid:$newId';
    }

    final slashIndex = trimmed.indexOf('/');
    if (slashIndex <= 0 || slashIndex == trimmed.length - 1) {
      return null;
    }

    final type = trimmed.substring(0, slashIndex);
    final originalId = trimmed.substring(slashIndex + 1);
    final newId = idMap[originalId];
    if (newId == null) return null;

    return '$type/$newId';
  }

  String _sourceLabel(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return 'Imported FHIR file';

    const maxLength = 60;
    final label = trimmed.length > maxLength
        ? '${trimmed.substring(0, maxLength - 1)}…'
        : trimmed;
    return 'Imported: $label';
  }

  String _sanitize(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (sanitized.isEmpty) return 'resource';
    return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
  }
}
