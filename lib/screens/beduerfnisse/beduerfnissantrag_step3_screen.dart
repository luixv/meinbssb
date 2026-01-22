import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:image_picker/image_picker.dart';

class BeduerfnissantragStep3Screen extends StatefulWidget {
  const BeduerfnissantragStep3Screen({
    this.userData,
    this.antrag,
    required this.isLoggedIn,
    required this.onLogout,
    required this.userRole,
    this.readOnly = false,
    super.key,
  });

  final UserData? userData;
  final BeduerfnisseAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;
  final WorkflowRole userRole;
  final bool readOnly;

  @override
  State<BeduerfnissantragStep3Screen> createState() =>
      _BeduerfnissantragStep3ScreenState();
}

class _BeduerfnissantragStep3ScreenState
    extends State<BeduerfnissantragStep3Screen> {
  Future<void> _uploadDocument(String documentType) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file == null) {
        return;
      }

      if (widget.antrag?.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler: Antragsnummer nicht gefunden'),
            ),
          );
        }
        return;
      }

      final bytes = await file.readAsBytes();

      // Upload the document
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antrag!.antragsnummer!,
        dateiname: file.name,
        fileBytes: bytes,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$documentType erfolgreich hochgeladen')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Hochladen')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Hochladen: $e')));
      }
    }
  }

  Future<void> _scanAndUploadDocument(String documentType) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Scan the document
      final scanResult = await apiService.scanDocument();

      if (scanResult == null) {
        // User cancelled scanning
        return;
      }

      if (widget.antrag?.antragsnummer == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler: Antragsnummer nicht gefunden'),
            ),
          );
        }
        return;
      }

      // Upload the scanned document
      final success = await apiService.uploadBedDateiForWBK(
        antragsnummer: widget.antrag!.antragsnummer!,
        dateiname: scanResult.fileName,
        fileBytes: scanResult.bytes,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$documentType erfolgreich gescannt und hochgeladen',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fehler beim Hochladen')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            floatingActionButton: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Back button (FAB) - always visible
                      KeyboardFocusFAB(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icons.arrow_back,
                        heroTag: 'fab_back_step3',
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Forward arrow - always visible for navigation
                      KeyboardFocusFAB(
                        heroTag: 'nextFromStep3Fab',
                        tooltip: 'Weiter',
                        semanticLabel: 'Weiter Button',
                        semanticHint: 'Weiter zum nächsten Schritt',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Schritt 3 abgeschlossen'),
                            ),
                          );
                        },
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: Semantics(
              label:
                  'Bedürfnisbescheinigung. Hier wird Ihr Bedürfnisantrag angezeigt.',
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Semantics(
                      header: true,
                      label: 'Bedürfnisbescheinigung',
                      child: ScaledText(
                        'Bedürfnisbescheinigung',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20 * fontSizeProvider.scaleFactor,
                          color: const Color.fromRGBO(11, 75, 16, 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingM),

                    // Additional text for existing WBK (under subtitle)
                    if (widget.antrag != null &&
                        widget.antrag!.wbkNeu == false) ...[
                      ScaledText(
                        'Kopie der vorhandenen WBK (Vorder und Rückseite)',
                        style: TextStyle(
                          fontSize: 16 * fontSizeProvider.scaleFactor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                    ],

                    // Display Bedürfnisantrag type
                    if (widget.antrag != null)
                      Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: UIConstants.cardColor,
                          borderRadius: BorderRadius.circular(
                            UIConstants.cornerRadius,
                          ),
                          border: Border.all(
                            color: UIConstants.defaultAppColor,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Bedürfnisantrag:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * fontSizeProvider.scaleFactor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingM),
                            ScaledText(
                              widget.antrag!.wbkNeu == true
                                  ? 'Ich beantrage ein Bedürfnis für eine neue WBK'
                                  : 'Ich beantrage ein Bedürfnis für eine bestehende WBK',
                              style: TextStyle(
                                fontSize: 16 * fontSizeProvider.scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Buttons for existing WBK
                    if (widget.antrag != null &&
                        widget.antrag!.wbkNeu == false) ...[
                      const SizedBox(height: UIConstants.spacingL),

                      // Vorderseite WBK Section
                      ScaledText(
                        'WBK',
                        style: UIStyles.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              UIStyles.bodyTextStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  () => _uploadDocument('Vorderseite WBK'),
                              icon: const Icon(Icons.upload_file),
                              label: ScaledText(
                                'Hochladen',
                                style: TextStyle(
                                  fontSize: 16 * fontSizeProvider.scaleFactor,
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
                              ),
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingM),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  () =>
                                      _scanAndUploadDocument('Vorderseite WBK'),
                              icon: const Icon(Icons.camera_alt),
                              label: ScaledText(
                                'Scannen',
                                style: TextStyle(
                                  fontSize: 16 * fontSizeProvider.scaleFactor,
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
