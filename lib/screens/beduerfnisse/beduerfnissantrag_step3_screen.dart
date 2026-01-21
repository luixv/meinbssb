import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_datei_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

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
  Future<List<BeduerfnisseDatei>>? _bedDateiFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.antrag?.antragsnummer != null) {
      _bedDateiFuture = _fetchBedDateiData();
    }
  }

  Future<List<BeduerfnisseDatei>> _fetchBedDateiData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (widget.antrag?.antragsnummer == null) {
      return [];
    }
    try {
      final antragsnummer = widget.antrag!.antragsnummer;
      if (antragsnummer == null) {
        return [];
      }
      return await apiService.getBedDateiByAntragsnummer(antragsnummer);
    } catch (e) {
      LoggerService.logError('Error fetching documents: $e');
      return [];
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        final bytes = await file.readAsBytes();
        final apiService = Provider.of<ApiService>(context, listen: false);

        if (widget.antrag?.antragsnummer == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: ScaledText(
                  'Fehler: Antragsnummer nicht gefunden',
                  style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
                ),
              ),
            );
          }
          return;
        }

        final result = await apiService.createBedDatei(
          antragsnummer: widget.antrag!.antragsnummer!,
          dateiname: file.name,
          fileBytes: bytes,
        );

        if (mounted) {
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: ScaledText(
                  'Dokument erfolgreich hochgeladen',
                  style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
                ),
              ),
            );
            // Refresh document list
            setState(() {
              _bedDateiFuture = _fetchBedDateiData();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ScaledText(
                  'Fehler beim Hochladen: ${result['error'] ?? 'Unbekannter Fehler'}',
                  style: const TextStyle(
                    fontSize: UIConstants.snackBarTextFontSize,
                  ),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      LoggerService.logError('Error uploading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: ScaledText(
              'Fehler beim Hochladen des Dokuments',
              style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument(BeduerfnisseDatei document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const ScaledText('Dokument löschen'),
            content: ScaledText(
              'Möchten Sie das Dokument "${document.dateiname}" wirklich löschen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const ScaledText('Abbrechen'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const ScaledText(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        if (widget.antrag?.antragsnummer == null) return;

        final success = await apiService.deleteBedDatei(
          widget.antrag!.antragsnummer!,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: ScaledText(
                  'Dokument erfolgreich gelöscht',
                  style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
                ),
              ),
            );
            // Refresh document list
            setState(() {
              _bedDateiFuture = _fetchBedDateiData();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: ScaledText(
                  'Fehler beim Löschen des Dokuments',
                  style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
                ),
              ),
            );
          }
        }
      } catch (e) {
        LoggerService.logError('Error deleting document: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText(
                'Fehler beim Löschen des Dokuments',
                style: TextStyle(fontSize: UIConstants.snackBarTextFontSize),
              ),
            ),
          );
        }
      }
    }
  }

  void _viewDocument(BeduerfnisseDatei document) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: UIConstants.defaultAppColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ScaledText(
                            document.dateiname,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Document content
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            Uint8List.fromList(document.fileBytes),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  ScaledText(
                                    'Dokument kann nicht angezeigt werden',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ScaledText(
                                    'Dateiformat wird nicht unterstützt',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung - Schritt 3',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung - Schritt 3',
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
                      // Add button - only show when not in read-only mode
                      if (!widget.readOnly)
                        KeyboardFocusFAB(
                          heroTag: 'addDocumentFab',
                          tooltip: 'Dokument hinzufügen',
                          semanticLabel: 'Dokument hinzufügen Button',
                          semanticHint: 'Neues Dokument hinzufügen',
                          onPressed: _uploadDocument,
                          icon: Icons.add,
                        ),
                      if (!widget.readOnly)
                        const SizedBox(height: UIConstants.spacingS),
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
            body: Padding(
              padding: UIConstants.screenPadding,
              child:
                  _bedDateiFuture == null
                      ? const Center(
                        child: ScaledText(
                          'Keine Antragsnummer verfügbar',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                      : FutureBuilder<List<BeduerfnisseDatei>>(
                        future: _bedDateiFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: UIConstants.defaultAppColor,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: ScaledText(
                                'Fehler beim Laden der Dokumente: ${snapshot.error}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          final documents = snapshot.data ?? [];

                          if (documents.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 64 * fontSizeProvider.scaleFactor,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  ScaledText(
                                    'Keine Dokumente hochgeladen',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  ScaledText(
                                    'Fügen Sie Nachweise hinzu mit dem + Button',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final doc = documents[index];
                              final fileSize = doc.fileBytes.length;
                              final fileSizeKB = (fileSize / 1024)
                                  .toStringAsFixed(1);

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  onTap: () => _viewDocument(doc),
                                  leading: Icon(
                                    Icons.description,
                                    color: UIConstants.primaryColor,
                                    size:
                                        UIConstants.iconSizeL *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  title: ScaledText(
                                    doc.dateiname,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: ScaledText(
                                    '$fileSizeKB KB',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: UIConstants.primaryColor,
                                        ),
                                        tooltip: 'Anzeigen',
                                        onPressed: () => _viewDocument(doc),
                                      ),
                                      if (!widget.readOnly)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Löschen',
                                          onPressed: () => _deleteDocument(doc),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ),
        );
      },
    );
  }
}
