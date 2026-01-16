import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step2_screen.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class BeduerfnissantragStep1Screen extends StatefulWidget {
  const BeduerfnissantragStep1Screen({
    this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    this.onBack,
    this.antrag,
    this.readOnly = false,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final VoidCallback? onBack;
  final BeduerfnisseAntrag? antrag;
  final bool readOnly;

  @override
  State<BeduerfnissantragStep1Screen> createState() =>
      _BeduerfnissantragStep1ScreenState();
}

class _BeduerfnissantragStep1ScreenState
    extends State<BeduerfnissantragStep1Screen> {
  String? _wbkType = 'neu'; // 'neu' or 'bestehend'
  String? _wbkColor = 'gelb'; // 'gelb' or 'gruen'
  String? _weaponType = 'kurz'; // 'kurz' or 'lang'
  final TextEditingController _anzahlController = TextEditingController(
    text: '0',
  );
  String? _selectedVerein;
  // Tracks if new antrag has been created/saved
  BeduerfnisseAntrag?
  _createdAntrag; // Stores the created antrag in create mode

  @override
  void initState() {
    super.initState();
    if (widget.antrag != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() async {
    final antrag = widget.antrag!;
    // Fetch fresh antrag data from API to ensure we have the latest values
    final apiService = Provider.of<ApiService>(context, listen: false);
    final antragsList = await apiService.getBedAntragByAntragsnummer(
      antrag.antragsnummer!,
    );

    if (antragsList.isNotEmpty && mounted) {
      final freshAntrag = antragsList.first;
      setState(() {
        _wbkType = freshAntrag.wbkNeu == true ? 'neu' : 'bestehend';
        _wbkColor = freshAntrag.wbkArt ?? 'gelb';
        // Map database values ('kurzwaffe', 'langwaffe') back to radio button values ('kurz', 'lang')
        final beduerfnisart = freshAntrag.beduerfnisart ?? 'kurzwaffe';
        _weaponType = beduerfnisart == 'kurzwaffe' ? 'kurz' : 'lang';
        _anzahlController.text = (freshAntrag.anzahlWaffen ?? 0).toString();
      });
    }
  }

  @override
  void dispose() {
    _anzahlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung - Erfassen der Daten',
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
                  KeyboardFocusFAB(
                    heroTag: 'backFromErfassenFab',
                    tooltip: 'Zurück',
                    semanticLabel: 'Zurück Button',
                    semanticHint: 'Zurück zur vorherigen Seite',
                    onPressed: () {
                      widget.onBack?.call();
                      Navigator.pop(context, true);
                    },
                    icon: Icons.arrow_back,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Save FAB (diskette icon) - only show when not read-only
                      if (!widget.readOnly)
                        KeyboardFocusFAB(
                          heroTag: 'saveFromErfassenFab',
                          tooltip: 'Speichern',
                          semanticLabel: 'Speichern Button',
                          semanticHint: 'Bedürfnisantrag speichern',
                          onPressed: () => _saveAntrag(),
                          icon: Icons.save,
                        ),
                      if (!widget.readOnly)
                        const SizedBox(height: UIConstants.spacingM),
                      // Forward arrow - always visible for navigation
                      KeyboardFocusFAB(
                        heroTag: 'nextFromErfassenFab',
                        tooltip: 'Weiter',
                        semanticLabel: 'Weiter Button',
                        semanticHint: 'Weiter zum nächsten Schritt',
                        onPressed: () {
                          _proceedToStep2();
                        },
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Erfassen der Daten. Hier können Sie die notwendigen Daten für Ihren Bedürfnisantrag erfassen.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Erfassen der Daten',
                        child: ScaledText(
                          'Erfassen der Daten',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Title
                      Semantics(
                        header: true,
                        label: 'Bedürfnisantrag',
                        child: ScaledText(
                          'Bedürfnisantrag',
                          style: UIStyles.formValueBoldStyle.copyWith(
                            fontSize:
                                UIStyles.formValueBoldStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Radio Group 1: WBK Type
                      Semantics(
                        label:
                            'Bedürfnisantrag Typ auswählen: neue oder bestehende WBK',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Ich beantrage ein Bedürfnis für eine neue WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'neu',
                                groupValue: _wbkType,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _wbkType = value;
                                          });
                                        },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Ich beantrage ein Bedürfnis für eine bestehende WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'bestehend',
                                groupValue: _wbkType,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _wbkType = value;
                                          });
                                        },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 2: WBK Color
                      Semantics(
                        label: 'WBK Art auswählen: Gelbe oder Grüne WBK',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Gelbe WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'gelb',
                                groupValue: _wbkColor,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _wbkColor = value;
                                          });
                                        },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Grüne WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'gruen',
                                groupValue: _wbkColor,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _wbkColor = value;
                                          });
                                        },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 3: Weapon Type
                      Semantics(
                        label:
                            'Bedürfnis für eine: Kurzwaffe oder Langwaffe auswählen',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Bedürfnis für eine:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Kurzwaffe',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'kurz',
                                groupValue: _weaponType,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _weaponType = value;
                                          });
                                        },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Langwaffe',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'lang',
                                groupValue: _weaponType,
                                onChanged:
                                    widget.readOnly
                                        ? null
                                        : (value) {
                                          setState(() {
                                            _weaponType = value;
                                          });
                                        },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Anzahl TextField
                      Semantics(
                        label:
                            'Ich besitze bereits ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}: Anzahl eingeben',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Ich besitze bereits ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            TextField(
                              controller: _anzahlController,
                              enabled: !widget.readOnly,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'),
                                ),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Anzahl',
                                border: OutlineInputBorder(),
                              ),
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Verein Dropdown
                      Semantics(
                        label: 'Verein der genehmigt auswählen',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Verein der genehmigt:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            DropdownButtonFormField<String>(
                              value: _selectedVerein,
                              onChanged:
                                  widget.readOnly
                                      ? null
                                      : (value) {
                                        setState(() {
                                          _selectedVerein = value;
                                        });
                                      },
                              decoration: const InputDecoration(
                                labelText: 'Verein auswählen',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                // TODO: Load from ZMI? - Erst- und Zweitvereine
                                DropdownMenuItem(
                                  value: 'verein1',
                                  child: ScaledText(
                                    'Verein 1 (Placeholder)',
                                    style: UIStyles.bodyTextStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyTextStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'verein2',
                                  child: ScaledText(
                                    'Verein 2 (Placeholder)',
                                    style: UIStyles.bodyTextStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyTextStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                ),
                              ],
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Gebührenerhebung
                      Semantics(
                        label: 'Gebührenerhebung',
                        child: ScaledText(
                          'Gebührenerhebung:',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingXXXL2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Saves the current form data without navigating away
  Future<void> _saveAntrag() async {
    if (!mounted) return;

    try {
      final beduerfnisartValue =
          _weaponType == 'kurz' ? 'kurzwaffe' : 'langwaffe';
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Edit mode: Update existing antrag (either from widget or newly created)
      if (widget.antrag != null || _createdAntrag != null) {
        try {
          final antrag = widget.antrag ?? _createdAntrag!;
          final updatedAntrag = BeduerfnisseAntrag(
            id: antrag.id,
            createdAt: antrag.createdAt,
            changedAt: DateTime.now(),
            deletedAt: antrag.deletedAt,
            antragsnummer: antrag.antragsnummer,
            personId: antrag.personId,
            statusId: antrag.statusId,
            wbkNeu: _wbkType == 'neu',
            wbkArt: _wbkColor,
            beduerfnisart: beduerfnisartValue,
            anzahlWaffen: int.tryParse(_anzahlController.text) ?? 0,
            vereinGenehmigt: antrag.vereinGenehmigt,
            email: antrag.email,
            bankdaten: antrag.bankdaten,
            abbuchungErfolgt: antrag.abbuchungErfolgt,
            bemerkung: antrag.bemerkung,
          );

          final success = await apiService.updateBedAntrag(updatedAntrag);

          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bedürfnisantrag aktualisiert')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fehler beim Aktualisieren des Antrags'),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler beim Aktualisieren: $e')),
            );
          }
        }
      } else {
        // Create mode: Create new antrag
        try {
          final newAntrag = await apiService.createBedAntrag(
            personId: widget.userData!.personId,
            statusId: BeduerfnisAntragStatus.entwurf,
            wbkNeu: _wbkType == 'neu',
            wbkArt: _wbkColor, // 'gelb' or 'gruen'
            beduerfnisart: beduerfnisartValue, // 'kurzwaffe' or 'langwaffe'
            anzahlWaffen: int.tryParse(_anzahlController.text) ?? 0,
            vereinGenehmigt: false,
            email: widget.userData?.email,
            abbuchungErfolgt: false,
          );

          if (mounted) {
            setState(() {
              // Mark antrag as created
              _createdAntrag = newAntrag; // Store the created antrag
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bedürfnisantrag erstellt: ${newAntrag.antragsnummer ?? 'N/A'}',
                ),
              ),
            );
          }
        } catch (e, stackTrace) {
          debugPrint('Error creating antrag: $e');
          debugPrint('Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fehler beim Erstellen: $e')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Speichern: $e')));
      }
    }
  }

  /// Proceeds to Step 2 (for both create and edit modes)
  Future<void> _proceedToStep2() async {
    if (!mounted) return;

    try {
      // Get the antrag to pass to Step 2
      late BeduerfnisseAntrag antragForStep2;

      if (widget.antrag != null) {
        // Edit mode: Use existing antrag
        antragForStep2 = widget.antrag!;
      } else if (_createdAntrag != null) {
        // Create mode: Use previously created antrag
        antragForStep2 = _createdAntrag!;
      } else {
        // Should not happen if button is disabled, but as a fallback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte speichern Sie zuerst das Formular'),
          ),
        );
        return;
      }

      // For now, assume the user is a "mitglied" - in the future this will come from user roles
      const userRole = WorkflowRole.mitglied;

      // Navigate to step 2 screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BeduerfnissantragStep2Screen(
                  userData: widget.userData,
                  antrag: antragForStep2,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                  userRole: userRole,
                  readOnly: widget.readOnly,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler beim Fortfahren: $e')));
      }
    }
  }
}
