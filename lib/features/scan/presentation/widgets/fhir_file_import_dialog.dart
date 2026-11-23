import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_wallet/core/di/injection.dart';
import 'package:health_wallet/core/theme/app_insets.dart';
import 'package:health_wallet/core/theme/app_text_style.dart';
import 'package:health_wallet/core/utils/build_context_extension.dart';
import 'package:health_wallet/core/utils/logger.dart';
import 'package:health_wallet/features/home/presentation/bloc/home_bloc.dart';
import 'package:health_wallet/features/records/domain/entity/patient/patient.dart';
import 'package:health_wallet/features/records/presentation/bloc/records_bloc.dart';
import 'package:health_wallet/features/sync/data/data_source/local/sync_local_data_source.dart';
import 'package:health_wallet/features/sync/domain/services/fhir_file_import_service.dart';
import 'package:health_wallet/features/user/domain/services/default_patient_service.dart';
import 'package:health_wallet/features/user/presentation/preferences_modal/sections/patient/bloc/patient_bloc.dart';
import 'package:health_wallet/gen/assets.gen.dart';

class FhirFileImportDialog extends StatefulWidget {
  const FhirFileImportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FhirFileImportDialog(),
    );
  }

  @override
  State<FhirFileImportDialog> createState() => _FhirFileImportDialogState();
}

class _FhirFileImportDialogState extends State<FhirFileImportDialog> {
  static const int _maxFileSizeBytes = 25 * 1024 * 1024;

  List<Patient> _patients = const [];
  String? _selectedPatientId;
  String? _pickedFileName;
  String? _pickedFileContent;

  String? _error;
  FhirFileImportResult? _result;

  bool _isLoadingPatients = true;
  bool _isPickingFile = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatients());
  }

  Future<void> _loadPatients() async {
    if (!mounted) return;

    final patientBloc = context.read<PatientBloc>();
    setState(() {
      _isLoadingPatients = true;
      _error = null;
    });

    try {
      if (patientBloc.state.patients.isEmpty) {
        await _requestPatientReload(patientBloc);
      }

      if (patientBloc.state.patients.isEmpty) {
        await getIt<DefaultPatientService>().createAndSetAsMain();
        patientBloc.add(const PatientPatientsLoaded());
        await _waitForPatients(
          patientBloc,
          timeout: const Duration(seconds: 6),
        );
      }

      final patients = patientBloc.state.patients;
      if (patients.isEmpty) {
        throw const FhirFileImportException(
          'No patients are available yet. Please create a patient first.',
        );
      }

      final previousSelection = _selectedPatientId;
      final selectedId = patients.any((p) => p.id == previousSelection)
          ? previousSelection
          : patients.first.id;

      if (!mounted) return;
      setState(() {
        _patients = patients;
        _selectedPatientId = selectedId;
      });
    } catch (e) {
      logger.e('Failed to load patients for FHIR import: $e');
      if (!mounted) return;
      setState(() {
        _error = e is FhirFileImportException
            ? e.message
            : 'Unable to load patients. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingPatients = false);
      }
    }
  }

  Future<void> _requestPatientReload(PatientBloc patientBloc) async {
    patientBloc.add(const PatientPatientsLoaded());
    await _waitForPatients(patientBloc, timeout: const Duration(seconds: 4));
  }

  Future<void> _waitForPatients(
    PatientBloc patientBloc, {
    required Duration timeout,
  }) async {
    if (patientBloc.state.patients.isNotEmpty) return;

    try {
      await patientBloc.stream
          .firstWhere((state) => state.patients.isNotEmpty)
          .timeout(timeout);
    } on TimeoutException {
      // The caller handles an empty patient list.
    } catch (e) {
      logger.w('Error while waiting for patients: $e');
    }
  }

  Patient? get _selectedPatient {
    final selectedId = _selectedPatientId;
    if (selectedId == null) return null;
    for (final patient in _patients) {
      if (patient.id == selectedId) return patient;
    }
    return null;
  }

  Future<void> _pickFile() async {
    if (_isImporting || _isPickingFile) return;

    setState(() {
      _isPickingFile = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowCompression: false,
        withData: true,
        withReadStream: false,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      if (!file.name.toLowerCase().endsWith('.json')) {
        throw const FhirFileImportException(
          'Please choose a .json file containing FHIR resources.',
        );
      }

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && file.path!.isNotEmpty) {
        final localFile = File(file.path!);
        if (!await localFile.exists()) {
          throw const FhirFileImportException(
            'The selected file could not be found.',
          );
        }
        bytes = await localFile.readAsBytes();
      }

      if (bytes == null) {
        throw const FhirFileImportException(
          'The selected file could not be read.',
        );
      }

      if (bytes.length > _maxFileSizeBytes) {
        throw const FhirFileImportException(
          'The selected file is too large. The maximum size is 25 MB.',
        );
      }

      final content = utf8.decode(bytes);

      if (!mounted) return;
      setState(() {
        _pickedFileName = file.name;
        _pickedFileContent = content;
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _error = 'The selected file is not valid UTF-8 text.';
      });
    } catch (e) {
      logger.e('Failed to pick JSON file: $e');
      if (!mounted) return;
      setState(() {
        _error = e is FhirFileImportException
            ? e.message
            : 'Failed to read the selected file.';
      });
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _runImport() async {
    if (_isImporting) return;

    final patient = _selectedPatient;
    final fileName = _pickedFileName;
    final content = _pickedFileContent;

    if (patient == null) {
      setState(() {
        _error = 'Please select a patient before importing.';
      });
      return;
    }
    if (fileName == null || content == null) {
      setState(() {
        _error = 'Please choose a .json file before importing.';
      });
      return;
    }

    final patientBloc = context.read<PatientBloc>();
    final homeBloc = context.read<HomeBloc>();
    final recordsBloc = context.read<RecordsBloc>();

    setState(() {
      _isImporting = true;
      _error = null;
    });

    try {
      final service = FhirFileImportService(getIt<SyncLocalDataSource>());
      final result = await service.importJsonFile(
        jsonContent: content,
        fileName: fileName,
        patient: patient,
      );

      await _refreshAfterImport(
        patient: patient,
        result: result,
        patientBloc: patientBloc,
        homeBloc: homeBloc,
        recordsBloc: recordsBloc,
      );

      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      logger.e('FHIR file import failed: $e');
      if (!mounted) return;
      setState(() {
        _error = e is FhirFileImportException
            ? e.message
            : 'Import failed. Please check the file and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _refreshAfterImport({
    required Patient patient,
    required FhirFileImportResult result,
    required PatientBloc patientBloc,
    required HomeBloc homeBloc,
    required RecordsBloc recordsBloc,
  }) async {
    PatientState patientState = patientBloc.state;

    try {
      patientBloc.add(
        PatientPatientsLoaded(
          preserveOrder: true,
          preservePatientId: patient.id,
        ),
      );
      patientState = await patientBloc.stream
          .firstWhere((state) {
            final group = state.patientGroups[patient.id];
            return group != null && group.sourceIds.contains(result.sourceId);
          })
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      logger.w('Patient reload after import timed out: $e');
      patientState = patientBloc.state;
    }

    if (patientBloc.state.selectedPatientId != patient.id) {
      patientBloc.add(PatientSelectionChanged(patientId: patient.id));
    }

    final sourceIds = <String>{
      ...(patientState.patientGroups[patient.id]?.sourceIds ??
          const <String>[]),
      result.sourceId,
      if (patient.sourceId.isNotEmpty) patient.sourceId,
    }.toList();

    homeBloc.add(HomeSourceChanged('All', patientSourceIds: sourceIds));

    recordsBloc.add(const RecordsInitialised());
    recordsBloc.add(RecordsSourceChanged(null, sourceIds: sourceIds));
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Color _errorColor(BuildContext context) {
    return context.isDarkMode ? const Color(0xFFFF8A80) : Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return PopScope(
      canPop: !_isImporting,
      child: Dialog(
        backgroundColor: colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: Insets.normal,
          vertical: Insets.large,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.theme.dividerColor),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Insets.normal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _result != null
                    ? _buildSuccessContent(context, _result!)
                    : _buildFormContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSuccessContent(
    BuildContext context,
    FhirFileImportResult result,
  ) {
    final message = result.importedCount == 1
        ? '1 resource imported for ${result.patientName}.'
        : '${result.importedCount} resources imported for ${result.patientName}.';

    return [
      Row(
        children: [
          Assets.icons.checkmarkCircleOutline.svg(
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              context.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: Insets.small),
          const Expanded(
            child: Text('Import completed', style: AppTextStyle.titleMedium),
          ),
        ],
      ),
      const SizedBox(height: Insets.normal),
      Text(message, style: AppTextStyle.bodyMedium),
      if (result.skippedPatients > 0) ...[
        const SizedBox(height: Insets.small),
        Text(
          '${result.skippedPatients} Patient resource(s) from the file were '
          'linked to the selected patient instead of creating duplicates.',
          style: AppTextStyle.bodySmall.copyWith(
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
      const SizedBox(height: Insets.normal),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: _close,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Insets.small),
            ),
            elevation: 0,
          ),
          child: const Text('Done'),
        ),
      ),
    ];
  }

  List<Widget> _buildFormContent(BuildContext context) {
    final selectedPatient = _selectedPatient;

    return [
      Row(
        children: [
          const Expanded(
            child: Text('Import FHIR file', style: AppTextStyle.titleMedium),
          ),
          IconButton(
            onPressed: _isImporting ? null : _close,
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      const SizedBox(height: Insets.small),
      Text(
        'Choose a .json file with FHIR resources and select the patient '
        'these resources belong to.',
        style: AppTextStyle.bodySmall.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      const SizedBox(height: Insets.normal),
      _buildPatientField(context),
      const SizedBox(height: Insets.normal),
      _buildFileField(context),
      if (_error != null) ...[
        const SizedBox(height: Insets.normal),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Insets.small),
          decoration: BoxDecoration(
            color: _errorColor(context).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Insets.small),
            border: Border.all(
              color: _errorColor(context).withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            _error!,
            style: AppTextStyle.bodySmall.copyWith(color: _errorColor(context)),
          ),
        ),
      ],
      const SizedBox(height: Insets.large),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isImporting ? null : _close,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Insets.small),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: Insets.small),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  _isImporting ||
                      _isLoadingPatients ||
                      _pickedFileContent == null ||
                      selectedPatient == null
                  ? null
                  : _runImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Insets.small),
                ),
                elevation: 0,
              ),
              child: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Import'),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildPatientField(BuildContext context) {
    if (_isLoadingPatients) {
      return Container(
        padding: const EdgeInsets.all(Insets.small),
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.dividerColor),
          borderRadius: BorderRadius.circular(Insets.small),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: Insets.small),
            Text('Loading patients...'),
          ],
        ),
      );
    }

    if (_patients.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No patients available.',
            style: AppTextStyle.bodySmall.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Insets.small),
          OutlinedButton(
            onPressed: _isImporting ? null : _loadPatients,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('import-patient-${_selectedPatientId ?? 'none'}'),
      initialValue: _selectedPatientId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Patient',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Insets.small),
        ),
      ),
      items: _patients.map((patient) {
        final source = patient.sourceId.isNotEmpty
            ? ' (${patient.sourceId})'
            : '';
        return DropdownMenuItem<String>(
          value: patient.id,
          child: Text(
            '${patient.displayTitle}$source',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isImporting
          ? null
          : (value) {
              setState(() => _selectedPatientId = value);
            },
    );
  }

  Widget _buildFileField(BuildContext context) {
    final fileName = _pickedFileName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _isImporting || _isPickingFile ? null : _pickFile,
          icon: Assets.icons.documentFile.svg(width: 18, height: 18),
          label: Text(
            _isPickingFile
                ? 'Opening file picker...'
                : fileName == null
                ? 'Choose .json file'
                : 'Choose another file',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.medium,
              vertical: Insets.smallNormal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Insets.small),
            ),
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: Insets.small),
          Row(
            children: [
              Assets.icons.documentFile.svg(
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.colorScheme.onSurface.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: Insets.extraSmall),
              Expanded(
                child: Text(
                  fileName,
                  style: AppTextStyle.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
