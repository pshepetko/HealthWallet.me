import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:health_wallet/core/di/injection.dart';
import 'package:health_wallet/core/services/external_files_service.dart';
import 'package:health_wallet/core/theme/app_text_style.dart';
import 'package:health_wallet/core/utils/logger.dart';
import 'package:health_wallet/features/scan/domain/entity/processing_session.dart';
import 'package:health_wallet/features/scan/presentation/widgets/session_list.dart';
import 'package:health_wallet/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_wallet/core/widgets/custom_app_bar.dart';
import 'package:health_wallet/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:health_wallet/features/scan/presentation/widgets/dialog_helper.dart';
import 'package:health_wallet/features/scan/presentation/widgets/fhir_file_import_dialog.dart';
import 'package:health_wallet/features/scan/presentation/widgets/import_actions.dart';
import 'package:health_wallet/features/scan/presentation/helpers/document_handler.dart';
import 'package:health_wallet/features/dashboard/presentation/helpers/page_view_navigation_controller.dart';
import 'package:health_wallet/core/utils/responsive.dart';

@RoutePage()
class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImportView();
  }
}

class ImportView extends StatefulWidget {
  const ImportView({super.key});

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> with DocumentHandler {
  late final PageViewNavigationController _navigationController;
  @override
  void initState() {
    super.initState();
    _navigationController = getIt<PageViewNavigationController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processExternalFiles();
    });
  }

  void _processExternalFiles() {
    final externalFileService = getIt<ExternalFilesService>();

    if (externalFileService.hasPendingFiles) {
      final paths = externalFileService.consumeFilePaths();
      if (paths.isNotEmpty) {
        context.read<ScanBloc>().add(
          DocumentImported(filePaths: paths.toList()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Import',
        automaticallyImplyLeading: false,
        extraTopPadding: context.isTablet ? 16 : 0,
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status case SessionCreated(:final session)) {
            if (session.origin == ProcessingOrigin.import) {
              navigateToFhirMapper(context, session);
            }
          }
        },
        builder: (context, state) {
          List<ProcessingSession> importSessions = state.sessions
              .where((element) => element.origin == ProcessingOrigin.import)
              .toList();

          return Padding(
            padding: EdgeInsets.only(
              left: context.screenHorizontalPadding,
              right: context.screenHorizontalPadding,
              top: context.isTablet ? 24.0 : 16.0,
              bottom: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (importSessions.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Active import sessions:",
                          style: AppTextStyle.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Only one processing session can run at a time!",
                          style: AppTextStyle.bodySmall,
                        ),
                        const SizedBox(height: 24),
                        Expanded(child: SessionList(sessions: importSessions)),
                        const SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 76,
                          ),
                          child: ImportActions(
                            onImportFile: () => _handleImportFile(context),
                            onImportDocument: () =>
                                _handleImportDocument(context),
                            onPickImage: () => _handlePickImage(context),
                            onScanDocument: () => _navigateToScanTab(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (importSessions.isEmpty)
                  if (context.isTablet)
                    Expanded(
                      child: Align(
                        alignment: const Alignment(0, -0.3),
                        child: SingleChildScrollView(
                          child: _buildEmptyState(context),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: _buildEmptyState(context),
                        ),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Assets.images.emptyScan.svg(),
          const SizedBox(height: 36),
          const Text(
            "No imports yet",
            style: AppTextStyle.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Import or scan documents to get started",
            style: AppTextStyle.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ImportActions(
              onImportFile: () => _handleImportFile(context),
              onImportDocument: () => _handleImportDocument(context),
              onPickImage: () => _handlePickImage(context),
              onScanDocument: () => _navigateToScanTab(context),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScanTab(BuildContext context) {
    _navigationController.navigateToPage(2);
    // Trigger auto-scan after navigation settles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          _triggerScan(context);
        }
      });
    });
  }

  Future<void> _triggerScan(BuildContext context) async {
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      if (context.mounted) {
        context.read<ScanBloc>().add(const ScanButtonPressed());
      }
    } else if (cameraStatus.isPermanentlyDenied) {
      if (context.mounted) {
        DialogHelper.showPermissionDeniedDialog(context);
      }
    } else {
      if (context.mounted) {
        DialogHelper.showPermissionRequiredDialog(
          context,
          () => _triggerScan(context),
        );
      }
    }
  }

  Future<void> _handleImportFile(BuildContext context) async {
    await FhirFileImportDialog.show(context);
  }

  Future<void> _handleImportDocument(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowCompression: false,
        withData: kIsWeb,
        withReadStream: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'webp',
          'tiff',
        ],
      );

      if (result == null || result.files.isEmpty) return;

      if (kIsWeb) {
        final pickedFiles = result.files
            .map((file) => '${file.name} (${file.bytes?.length ?? 0} bytes)')
            .join(', ');
        logger.w('Web document import is not supported yet: $pickedFiles');
        if (context.mounted) {
          _showMessage(
            context,
            'Document import is not available in the web version yet. '
            'Please use the mobile or desktop app.',
          );
        }
        return;
      }

      final validPaths = <String>[];

      for (final file in result.files) {
        final path = file.path;
        if (path == null || path.isEmpty) continue;
        if (await File(path).exists()) {
          validPaths.add(path);
        }
      }

      if (validPaths.isNotEmpty && context.mounted) {
        context.read<ScanBloc>().add(DocumentImported(filePaths: validPaths));
      }
    } catch (e, stackTrace) {
      logger.e('Failed to import documents', e, stackTrace);
      if (context.mounted) {
        _showMessage(context, 'Failed to import documents. Please try again.');
      }
    }
  }

  Future<void> _handlePickImage(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isEmpty) return;

      if (kIsWeb) {
        final pickedImages = <String>[];
        for (final image in images) {
          final bytes = await image.readAsBytes();
          pickedImages.add('${image.name} (${bytes.length} bytes)');
        }
        logger.w('Web image import is not supported yet: $pickedImages');
        if (context.mounted) {
          _showMessage(
            context,
            'Image import is not available in the web version yet. '
            'Please use the mobile or desktop app.',
          );
        }
        return;
      }

      final validPaths = <String>[];
      for (final image in images) {
        if (await File(image.path).exists()) {
          validPaths.add(image.path);
        }
      }

      if (validPaths.isNotEmpty && context.mounted) {
        context.read<ScanBloc>().add(DocumentImported(filePaths: validPaths));
      }
    } catch (e, stackTrace) {
      logger.e('Failed to import images', e, stackTrace);
      if (context.mounted) {
        _showMessage(context, 'Failed to import images. Please try again.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
