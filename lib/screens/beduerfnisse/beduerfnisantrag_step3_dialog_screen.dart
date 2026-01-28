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
  String? _errorMessage;

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    final contextToUse = context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(contextToUse);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _uploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (_labelController.text.trim().isEmpty) {
      _showError('Bitte geben Sie eine Beschreibung für die Datei ein.');
      return;
    }
    final picker = ImagePicker();
    try {
      setState(() {
        _isUploadingDocument = true;
      });
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      final bytes = await pickedFile.readAsBytes();
      if (widget.antragsnummer == null) {
        _showError('Antragsnummer nicht gefunden');
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: pickedFile.name,
        fileBytes: bytes,
        label: _labelController.text.trim(),
      );
      setState(() {
        _isUploadingDocument = false;
      });
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showError('Fehler beim Hochladen');
      }
    } catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      _showError('Fehler beim Hochladen: $e');
    }
  }

  Future<void> _scanAndUploadDocument(
    BuildContext context,
    String documentType,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (_labelController.text.trim().isEmpty) {
      _showError('Bitte geben Sie eine Beschreibung für die Datei ein.');
      return;
    }
    final picker = ImagePicker();
    try {
      setState(() {
        _isUploadingDocument = true;
      });
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) {
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      final bytes = await pickedFile.readAsBytes();
      if (widget.antragsnummer == null) {
        _showError('Antragsnummer nicht gefunden');
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: pickedFile.name,
        fileBytes: bytes,
        label: _labelController.text.trim(),
      );
      setState(() {
        _isUploadingDocument = false;
      });
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showError('Fehler beim Hochladen');
      }
    } catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      _showError('Fehler beim Scannen: $e');
    }
  }

  Future<void> _scanDocumentWithEdgeRecognition(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (_labelController.text.trim().isEmpty) {
      _showError('Bitte geben Sie eine Beschreibung für die Datei ein.');
      return;
    }
    setState(() {
      _isUploadingDocument = true;
    });
    try {
      final scanResult = await apiService.scanDocument();
      if (scanResult == null) {
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      if (widget.antragsnummer == null) {
        _showError('Antragsnummer nicht gefunden');
        setState(() {
          _isUploadingDocument = false;
        });
        return;
      }
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antragsnummer!,
        dateiname: scanResult.fileName,
        fileBytes: scanResult.bytes,
        label: _labelController.text.trim(),
      );
      setState(() {
        _isUploadingDocument = false;
      });
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        _showError('Fehler beim Hochladen');
      }
    } catch (e) {
      setState(() {
        _isUploadingDocument = false;
      });
      _showError('Fehler beim Scannen: $e');
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
          child: ConstrainedBox(
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
                      if (_errorMessage != null) ...[
                        const SizedBox(height: UIConstants.spacingS),
                        Container(
                          padding: const EdgeInsets.all(UIConstants.spacingS),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              UIConstants.cornerRadius,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: UIConstants.spacingS),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    color: Colors.red,
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                          const SizedBox(width: UIConstants.spacingM),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isUploadingDocument
                                      ? null
                                      : () => _scanDocumentWithEdgeRecognition(
                                        context,
                                      ),
                              icon: Icon(
                                Icons.document_scanner,
                                color: UIConstants.buttonTextColor,
                              ),
                              label: ScaledText(
                                'Scannen (mit Randerkennung)',
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
        );
      },
    );
  }
}
