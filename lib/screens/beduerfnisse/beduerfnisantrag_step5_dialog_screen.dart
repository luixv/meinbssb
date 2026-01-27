import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:image_picker/image_picker.dart';

class BeduerfnisantragStep3Dialog extends StatefulWidget {
  const BeduerfnisantragStep3Dialog({required this.antragsnummer, super.key});
  final int? antragsnummer;

  @override
  State<BeduerfnisantragStep3Dialog> createState() =>
      _BeduerfnisantragStep3DialogState();
}

class _BeduerfnisantragStep3DialogState
    extends State<BeduerfnisantragStep3Dialog> {
  bool _isUploadingDocument = false;
  final TextEditingController _labelController = TextEditingController();

  Future<void> _scanAndUploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    // Check if label is empty
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte geben Sie eine Beschreibung für die Datei ein.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Pick image using image picker (simulate scanning)
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        // User cancelled
        return;
      }

      final bytes = await pickedFile.readAsBytes();

      if (widget.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Antragsnummer nicht gefunden'),
              backgroundColor: Colors.red,
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
        dateiname: pickedFile.name,
        fileBytes: bytes,
        label: _labelController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        if (success) {
          Navigator.of(context).pop(true); // Close parent dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Hochladen'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Scannen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    // Check if label is empty
    if (_labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte geben Sie eine Beschreibung für die Datei ein.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Open file explorer to pick a file
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        // User cancelled
        return;
      }

      final bytes = await pickedFile.readAsBytes();

      if (widget.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Antragsnummer nicht gefunden'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingDocument = true;
      });

      // Upload the selected document
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: pickedFile.name,
        fileBytes: bytes,
        label: _labelController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        if (success) {
          Navigator.of(context).pop(true); // Close parent dialog on success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Hochladen'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingDocument = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Scannen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          ),
          backgroundColor: UIConstants.backgroundColor,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(UIConstants.spacingL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dialog Title
                        Row(
                          children: [
                            Icon(
                              Icons.file_upload,
                              color: UIConstants.defaultAppColor,
                              size: 28,
                            ),
                            const SizedBox(width: UIConstants.spacingM),
                            Expanded(
                              child: ScaledText(
                                'WBK-Dokument hochladen',
                                style: UIStyles.titleStyle.copyWith(
                                  fontSize:
                                      UIStyles.titleStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  color: UIConstants.defaultAppColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingM),

                        const SizedBox(height: UIConstants.spacingXS),
                        TextField(
                          controller: _labelController,
                          decoration: InputDecoration(
                            labelText: 'Beschreibung *',
                            hintText: 'Beschreibung des Dokuments',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.spacingM,
                              vertical: UIConstants.spacingM,
                            ),
                          ),
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        ScaledText(
                          'Bitte laden Sie Vorder- und Rückseite Ihrer WBK hoch oder scannen Sie diese ein.',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isUploadingDocument
                                        ? null
                                        : () => _uploadDocument(context, 'WBK'),
                                icon: Icon(
                                  Icons.upload_file,
                                  color: UIConstants.buttonTextColor,
                                ),
                                label: ScaledText(
                                  'Hochladen',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIConstants.buttonFontSize *
                                        fontSizeProvider.scaleFactor,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      UIConstants.submitButtonBackground,
                                  foregroundColor: UIConstants.buttonTextColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UIConstants.spacingM,
                                    vertical: UIConstants.spacingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.cornerRadius,
                                    ),
                                  ),
                                  elevation: 2,
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
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: UIConstants.buttonTextColor,
                                ),
                                label: ScaledText(
                                  'Scannen',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIConstants.buttonFontSize *
                                        fontSizeProvider.scaleFactor,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      UIConstants.submitButtonBackground,
                                  foregroundColor: UIConstants.buttonTextColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UIConstants.spacingM,
                                    vertical: UIConstants.spacingM,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.cornerRadius,
                                    ),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingXXL),
                      ],
                    ),
                  ),
                  // Close button (FAB)
                  Positioned(
                    bottom: UIConstants.spacingM,
                    right: UIConstants.spacingM,
                    child: FloatingActionButton(
                      heroTag: 'fab_close_upload_dialog',
                      mini: true,
                      backgroundColor: UIConstants.submitButtonBackground,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: UIConstants.buttonTextColor,
                      ),
                    ),
                  ),
                  // Loading overlays
                  if (_isUploadingDocument)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: UIConstants.overlayColor,
                          borderRadius: BorderRadius.circular(
                            UIConstants.cornerRadius,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UIConstants.circularProgressIndicator,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingM),
                              ScaledText(
                                'Wird hochgeladen...',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
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
