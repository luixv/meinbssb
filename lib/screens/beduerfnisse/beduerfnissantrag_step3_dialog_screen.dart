import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meinbssb/widgets/dialog_fabs.dart';

class BeduerfnissantragStep3Dialog extends StatefulWidget {
  const BeduerfnissantragStep3Dialog({required this.antragsnummer, super.key});

  final int? antragsnummer;

  @override
  State<BeduerfnissantragStep3Dialog> createState() =>
      _BeduerfnissantragStep3DialogState();
}

class _BeduerfnissantragStep3DialogState
    extends State<BeduerfnissantragStep3Dialog> {
  final bool _isLoading = false;
  bool _isUploadingDocument = false;

  Future<void> _uploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file == null) {
        return;
      }

      if (widget.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler: Antragsnummer nicht gefunden'),
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingDocument = true;
      });

      final bytes = await file.readAsBytes();

      // Upload the document
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: file.name,
        fileBytes: bytes,
      );

      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$documentType erfolgreich hochgeladen')),
          );
          Navigator.of(context).pop(true); // Close dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Hochladen')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Hochladen: $e')));
      }
    }
  }

  Future<void> _scanAndUploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Scan the document
      final scanResult = await apiService.scanDocument();

      if (scanResult == null) {
        // User cancelled scanning
        return;
      }

      if (widget.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler: Antragsnummer nicht gefunden'),
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingDocument = true;
      });

      // Upload the scanned document
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: scanResult.fileName,
        fileBytes: scanResult.bytes,
      );

      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$documentType erfolgreich gescannt und hochgeladen',
              ),
            ),
          );
          Navigator.of(context).pop(true); // Close dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Hochladen')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Scannen: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Dialog(
          insetPadding: const EdgeInsets.all(UIConstants.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          backgroundColor: UIConstants.backgroundColor,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Scaffold(
              backgroundColor: UIConstants.backgroundColor,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(UIConstants.spacingL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dialog Title
                          ScaledText(
                            'WBK hochladen',
                            style: UIStyles.titleStyle.copyWith(
                              fontSize:
                                  UIStyles.titleStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                              color: UIConstants.defaultAppColor,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingL),

                          // WBK Section
                          ScaledText(
                            'Kopie der vorhandenen WBK (Vorder und Rückseite)',
                            style: UIStyles.bodyTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  UIStyles.bodyTextStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isUploadingDocument
                                          ? null
                                          : () =>
                                              _uploadDocument(context, 'WBK'),
                                  icon: const Icon(Icons.upload_file),
                                  label: ScaledText(
                                    'Hochladen',
                                    style: TextStyle(
                                      fontSize:
                                          16 * fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        UIConstants.submitButtonBackground,
                                    foregroundColor:
                                        UIConstants.buttonTextColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: UIConstants.spacingM,
                                      vertical: UIConstants.spacingM,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingM),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isUploadingDocument
                                          ? null
                                          : () => _scanAndUploadDocument(
                                            context,
                                            'WBK',
                                          ),
                                  icon: const Icon(Icons.camera_alt),
                                  label: ScaledText(
                                    'Scannen',
                                    style: TextStyle(
                                      fontSize:
                                          16 * fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        UIConstants.submitButtonBackground,
                                    foregroundColor:
                                        UIConstants.buttonTextColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: UIConstants.spacingM,
                                      vertical: UIConstants.spacingM,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // FAB Close button
                  Positioned(
                    bottom: UIConstants.dialogFabTightBottom,
                    right: UIConstants.dialogFabTightRight,
                    child: DialogFABs(
                      children: [
                        FloatingActionButton(
                          heroTag: 'fab_close_upload_dialog',
                          mini: true,
                          backgroundColor: UIConstants.submitButtonBackground,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            color: UIConstants.buttonTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Loading overlays
                  if (_isLoading || _isUploadingDocument)
                    Positioned.fill(
                      child: Container(
                        color: UIConstants.overlayColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UIConstants.circularProgressIndicator,
                                ),
                              ),
                              if (_isUploadingDocument) ...[
                                const SizedBox(height: UIConstants.spacingM),
                                const Text(
                                  'Wird hochgeladen...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
