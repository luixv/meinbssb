import 'package:meinbssb/widgets/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_dialog_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step4_screen.dart';
import 'package:meinbssb/models/beduerfnis_datei_zuord_data.dart';
import 'package:meinbssb/services/api_service.dart';

import 'dart:typed_data';

class BeduerfnisantragStep3Screen extends StatefulWidget {
  const BeduerfnisantragStep3Screen({
    this.userData,
    this.antrag,
    required this.isLoggedIn,
    required this.onLogout,
    required this.userRole,
    this.readOnly = false,
    super.key,
  });

  final UserData? userData;
  final BeduerfnisAntrag? antrag;
  final bool isLoggedIn;
  final Function() onLogout;
  final WorkflowRole userRole;
  final bool readOnly;

  @override
  State<BeduerfnisantragStep3Screen> createState() =>
      _BeduerfnisantragStep3ScreenState();
}

class _BeduerfnisantragStep3ScreenState
    extends State<BeduerfnisantragStep3Screen> {
  // Removed buildAntragTypeSummaryBox; now using AntragTypeSummaryBox widget.

  late Future<List<BeduerfnisDateiZuord>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _fetchDocuments();
  }

  Future<List<BeduerfnisDateiZuord>> _fetchDocuments() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    if (widget.antrag?.antragsnummer == null) {
      return [];
    }

    // Get the bed_datei_zuord entries (without fetching file data)
    return await apiService.getBedDateiZuordByAntragsnummer(
      widget.antrag!.antragsnummer!,
      'WBK',
    );
  }

  void _viewDocument(
    BuildContext context,
    BeduerfnisDateiZuord document,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Fetch the actual bed_datei to get file data only when viewing
    final datei = await apiService.getBedDateiById(document.dateiId);
    if (datei == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden des Dokuments')),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (dialogContext) => Semantics(
            label: 'Dokumentvorschau',
            dialog: true,
            enabled: true,
            child: Dialog(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
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
                            child: Semantics(
                              header: true,
                              label: 'Dokumenttitel: ${document.label ?? datei.dateiname}',
                              child: ScaledText(
                                document.label ?? datei.dateiname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Dialogfenster schließen',
                            hint: 'Dokumentvorschau schließen',
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              tooltip: 'Vorschau schließen',
                              onPressed: () => Navigator.of(dialogContext).pop(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.memory(
                            Uint8List.fromList(datei.fileBytes),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text('Fehler beim Laden des Bildes'),
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

  Future<void> _deleteDocument(BeduerfnisDateiZuord document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => DeleteConfirmDialog(
            title: 'Dokument löschen',
            message: 'Möchten Sie dieses Dokument wirklich löschen?',
            onCancel: () => Navigator.of(ctx).pop(false),
            onDelete: () => Navigator.of(ctx).pop(true),
          ),
    );

    if (confirmed != true) return;

    final apiService = Provider.of<ApiService>(context, listen: false);
    final success = await apiService.deleteBedDateiById(document.dateiId);

    if (mounted) {
      if (success) {
        setState(() {
          _documentsFuture = _fetchDocuments();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Löschen des Dokuments')),
        );
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
                      Semantics(
                        button: true,
                        label: 'Zurück Button',
                        hint: 'Zum vorherigen Schritt zurückkehren',
                        onTap: () => Navigator.of(context).pop(),
                        child: KeyboardFocusFAB(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icons.arrow_back,
                          heroTag: 'fab_back_step3',
                          tooltip: 'Zurück',
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add button to open upload dialog
                      KeyboardFocusFAB(
                        heroTag: 'addDocumentFab',
                        tooltip: 'Dokument hinzufügen',
                        semanticLabel: 'Dokument hinzufügen Button',
                        semanticHint:
                            'Öffnet Dialog zum Hochladen von Dokumenten',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (dialogContext) => BeduerfnisantragStep3Dialog(
                                  antragsnummer: widget.antrag?.antragsnummer,
                                ),
                          ).then((_) {
                            // Refresh document list after dialog is closed
                            setState(() {
                              _documentsFuture = _fetchDocuments();
                            });
                          });
                        },
                        icon: Icons.add,
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      // Forward arrow - always visible for navigation
                      KeyboardFocusFAB(
                        heroTag: 'nextFromStep3Fab',
                        tooltip: 'Weiter',
                        semanticLabel: 'Weiter Button',
                        semanticHint: 'Weiter zum nächsten Schritt',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return BeduerfnisantragStep4Screen(
                                  userData: widget.userData,
                                  isLoggedIn: widget.isLoggedIn,
                                  onLogout: widget.onLogout,
                                  antrag: widget.antrag,
                                  userRole: widget.userRole,
                                  readOnly: widget.readOnly,
                                );
                              },
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
                    Semantics(
                      label: 'Beschreibung der erforderlichen Dokumentation',
                      child: ScaledText(
                        'Kopie der vorhandenen WBK\n (Vorder und Rückseite)',
                        style: TextStyle(
                          fontSize: 16 * fontSizeProvider.scaleFactor,
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingM),

                    /*
                    // Display Bedürfnisantrag type summary
                    if (widget.userData != null)
                      AntragTypeSummaryBox(
                        wbkNeu: widget.userData?.wbkNeu,
                        antragWbkNeu: widget.antrag?.wbkNeu,
                      ),
                    const SizedBox(height: UIConstants.spacingL),
*/
                    // Document List Section
                    Semantics(
                      header: true,
                      label: 'Hochgeladene Dokumente',
                      child: ScaledText(
                        'Hochgeladene Dokumente:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * fontSizeProvider.scaleFactor,
                          color: UIConstants.defaultAppColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingM),

                    FutureBuilder<List<BeduerfnisDateiZuord>>(
                      future: _documentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('Fehler: ${snapshot.error}');
                        }
                        final documents = snapshot.data ?? [];
                        if (documents.isEmpty) {
                          return const ScaledText(
                            'Keine Dokumente hochgeladen.',
                          );
                        }
                        return Semantics(
                          label: 'Liste mit ${documents.length} hochgeladenen Dokumenten',
                          list: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final doc = documents[index];
                              final docLabel = doc.label ??
                                  'Dokument ${doc.id ?? index + 1}';
                              return Semantics(
                                label: '$docLabel. Element ${index + 1} von ${documents.length}',
                                button: true,
                                child: Card(
                                  margin: const EdgeInsets.only(
                                    bottom: UIConstants.spacingM,
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.description,
                                      color: UIConstants.defaultAppColor,
                                    ),
                                    title: ScaledText(
                                      docLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Semantics(
                                          button: true,
                                          label: 'Vorschau anzeigen für $docLabel',
                                          hint: 'Zeigt eine vergrößerte Vorschau des Dokuments an',
                                          onTap: () => _viewDocument(context, doc),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.preview,
                                              color: UIConstants.primaryColor,
                                            ),
                                            tooltip: 'Vorschau',
                                            onPressed:
                                                () => _viewDocument(context, doc),
                                          ),
                                        ),
                                        Semantics(
                                          button: true,
                                          label: 'Löschen von $docLabel',
                                          hint: 'Entfernt dieses Dokument permanent',
                                          onTap: () => _deleteDocument(doc),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: UIConstants.deleteIcon,
                                            ),
                                            tooltip: 'Löschen',
                                            onPressed: () => _deleteDocument(doc),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    // Add extra space at the bottom for visual comfort
                    const SizedBox(height: UIConstants.spacingXXXL2),
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
