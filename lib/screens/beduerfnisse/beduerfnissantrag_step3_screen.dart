import 'package:meinbssb/widgets/delete_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step3_dialog_screen.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step4_screen.dart';
import 'package:meinbssb/models/beduerfnisse_datei_zuord_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'dart:typed_data';

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
  late Future<List<BeduerfnisseDateiZuord>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _fetchDocuments();
  }

  Future<List<BeduerfnisseDateiZuord>> _fetchDocuments() async {
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

  void _viewDocument(BuildContext context, BeduerfnisseDateiZuord document) async {
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
          (dialogContext) => Dialog(
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
                          child: ScaledText(
                            document.label ?? datei.dateiname,
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

  Future<void> _deleteDocument(BeduerfnisseDateiZuord document) async {
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
                                (context) => BeduerfnissantragStep3Dialog(
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
                              builder:
                                  (context) => BeduerfnissantragStep4Screen(
                                    userData: widget.userData,
                                    isLoggedIn: widget.isLoggedIn,
                                    onLogout: widget.onLogout,
                                    antrag: widget.antrag,
                                  ),
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

                    // Display Bedürfnisantrag type summary
                    if (widget.antrag != null)
                      Container(
                        width: double.infinity,
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
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: ScaledText(
                                  widget.antrag!.wbkNeu == true
                                      ? 'Ich beantrage ein Bedürfnis für eine neue WBK'
                                      : 'Ich beantrage ein Bedürfnis für eine bestehende WBK',
                                  style: TextStyle(
                                    fontSize: 16 * fontSizeProvider.scaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: UIConstants.spacingL),

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

                    FutureBuilder<List<BeduerfnisseDateiZuord>>(
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
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: UIConstants.spacingM,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.description,
                                  color: UIConstants.defaultAppColor,
                                ),
                                title: ScaledText(
                                  doc.label ?? 'Dokument ${doc.id ?? index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_red_eye,
                                        color: UIConstants.primaryColor,
                                      ),
                                      onPressed:
                                          () => _viewDocument(context, doc),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: UIConstants.deleteIcon,
                                      ),
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
