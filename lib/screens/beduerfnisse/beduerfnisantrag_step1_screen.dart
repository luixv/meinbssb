import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step2_screen.dart';
import 'package:meinbssb/services/api/workflow_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class BeduerfnisantragStep1Screen extends StatefulWidget {
  const BeduerfnisantragStep1Screen({
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
  final BeduerfnisAntrag? antrag;
  final bool readOnly;

  @override
  State<BeduerfnisantragStep1Screen> createState() =>
      _BeduerfnisantragStep1ScreenState();
}

class _BeduerfnisantragStep1ScreenState
    extends State<BeduerfnisantragStep1Screen> {
  /// Returns true if the form has unsaved changes compared to the original antrag (or initial values)
  bool _isDirty() {
    final antrag = widget.antrag ?? _createdAntrag;
    final beduerfnisartValue =
        _weaponType == 'kurz' ? 'kurzwaffe' : 'langwaffe';
    final anzahl = int.tryParse(_anzahlController.text) ?? 0;
    if (antrag == null) {
      // If no antrag exists yet, consider dirty if any field is not default
      return _wbkType != 'neu' ||
          _wbkColor != 'gelb' ||
          _weaponType != 'kurz' ||
          anzahl != 0;
    }
    if ((antrag.wbkNeu == true ? 'neu' : 'bestehend') != _wbkType) return true;
    if ((antrag.wbkArt ?? 'gelb') != _wbkColor) return true;
    if ((antrag.beduerfnisart ?? 'kurzwaffe') != beduerfnisartValue) {
      return true;
    }
    if ((antrag.anzahlWaffen ?? 0) != anzahl) return true;
    // Verein and other fields can be added if needed
    return false;
  }

  String? _wbkType = 'neu'; // 'neu' or 'bestehend'
  String? _wbkColor = 'gelb'; // 'gelb' or 'gruen'
  String? _weaponType = 'kurz'; // 'kurz' or 'lang'
  final TextEditingController _anzahlController = TextEditingController(
    text: '0',
  );
  String? _selectedVerein;
  // Tracks if new antrag has been created/saved
  BeduerfnisAntrag? _createdAntrag; // Stores the created antrag in create mode

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
          label: 'Bedürfnisbescheinigung - Schritt 1: Erfassen der Daten',
          hint:
              'Erster Schritt der Antragstellung. Geben Sie die Basisdaten für Ihren Bedürfnisantrag ein',
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
                  Semantics(
                    button: true,
                    enabled: true,
                    label: 'Zurück zur Übersicht',
                    hint: 'Doppeltippen um zur vorherigen Seite zurückzukehren',
                    child: KeyboardFocusFAB(
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
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Save FAB (diskette icon) - only show when not read-only
                      if (!widget.readOnly)
                        Semantics(
                          button: true,
                          enabled: true,
                          label: 'Bedürfnisantrag speichern',
                          hint:
                              'Doppeltippen um Ihre Eingaben zu speichern ohne fortzufahren',
                          child: KeyboardFocusFAB(
                            heroTag: 'saveFromErfassenFab',
                            tooltip: 'Speichern',
                            semanticLabel: 'Speichern Button',
                            semanticHint: 'Bedürfnisantrag speichern',
                            onPressed: () => _saveAntrag(),
                            icon: Icons.save,
                          ),
                        ),
                      if (!widget.readOnly)
                        const SizedBox(height: UIConstants.spacingM),
                      // Forward arrow - always visible for navigation
                      Semantics(
                        button: true,
                        enabled: true,
                        label: 'Weiter zu Schritt 2',
                        hint:
                            'Doppeltippen um Daten zu speichern und zum nächsten Schritt fortzufahren',
                        child: KeyboardFocusFAB(
                          heroTag: 'nextFromErfassenFab',
                          tooltip: 'Weiter',
                          semanticLabel: 'Weiter Button',
                          semanticHint: 'Weiter zum nächsten Schritt',
                          onPressed: () {
                            _proceedToNextStep();
                          },
                          icon: Icons.arrow_forward,
                        ),
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
                hint:
                    'Scrollen Sie nach unten um alle Formularfelder auszufüllen',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Erfassen der Daten',
                        hint: 'Hauptüberschrift des Formulars',
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
                        hint: 'Abschnittsüberschrift für Antragstyp',
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
                        hint: 'Wählen Sie eine der beiden Optionen aus',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label:
                                  'Option 1: Neue WBK${_wbkType == "neu" ? ", ausgewählt" : ""}',
                              hint:
                                  _wbkType == 'neu'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                            Semantics(
                              label:
                                  'Option 2: Bestehende WBK${_wbkType == "bestehend" ? ", ausgewählt" : ""}',
                              hint:
                                  _wbkType == 'bestehend'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 2: WBK Color
                      Semantics(
                        label: 'WBK Art auswählen: Gelbe oder Grüne WBK',
                        hint: 'Wählen Sie die Farbe der Waffenbesitzkarte aus',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label:
                                  'Option 1: Gelbe WBK${_wbkColor == "gelb" ? ", ausgewählt" : ""}',
                              hint:
                                  _wbkColor == 'gelb'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                            Semantics(
                              label:
                                  'Option 2: Grüne WBK${_wbkColor == "gruen" ? ", ausgewählt" : ""}',
                              hint:
                                  _wbkColor == 'gruen'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 3: Weapon Type
                      Semantics(
                        label:
                            'Bedürfnis für eine: Kurzwaffe oder Langwaffe auswählen',
                        hint: 'Wählen Sie den Waffentyp für Ihren Antrag aus',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              label: 'Bedürfnis für eine',
                              hint: 'Unterüberschrift für Waffentyp-Auswahl',
                              child: ScaledText(
                                'Bedürfnis für eine:',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Semantics(
                              label:
                                  'Option 1: Kurzwaffe${_weaponType == "kurz" ? ", ausgewählt" : ""}',
                              hint:
                                  _weaponType == 'kurz'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                            Semantics(
                              label:
                                  'Option 2: Langwaffe${_weaponType == "lang" ? ", ausgewählt" : ""}',
                              hint:
                                  _weaponType == 'lang'
                                      ? 'Aktuell ausgewählt'
                                      : 'Doppeltippen um auszuwählen',
                              child: Transform.translate(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Anzahl TextField
                      Semantics(
                        label:
                            'Ich besitze bereits ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}: Anzahl eingeben',
                        hint:
                            'Geben Sie die Anzahl der bereits besessenen Waffen ein',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              label:
                                  'Ich besitze bereits ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}',
                              hint: 'Unterüberschrift für Anzahl-Eingabefeld',
                              child: ScaledText(
                                'Ich besitze bereits ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}:',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            Semantics(
                              textField: true,
                              label:
                                  'Anzahl der bereits besessenen ${_weaponType == 'kurz' ? 'Kurzwaffen' : 'Langwaffen'}',
                              hint:
                                  'Geben Sie eine Zahl ein. Aktueller Wert: ${_anzahlController.text}',
                              enabled: !widget.readOnly,
                              child: TextField(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Verein Dropdown
                      Semantics(
                        label: 'Verein der genehmigt auswählen',
                        hint:
                            'Wählen Sie den genehmigenden Verein aus der Dropdown-Liste aus',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              label: 'Verein der genehmigt',
                              hint: 'Unterüberschrift für Vereinsauswahl',
                              child: ScaledText(
                                'Verein der genehmigt:',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Semantics(
                              button: true,
                              label:
                                  'Vereinsauswahl Dropdown${_selectedVerein != null ? ", ausgewählt: $_selectedVerein" : ""}',
                              hint:
                                  widget.readOnly
                                      ? 'Nicht änderbar'
                                      : 'Doppeltippen um Verein auszuwählen',
                              enabled: !widget.readOnly,
                              child: DropdownButtonFormField<String>(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Gebührenerhebung
                      Semantics(
                        header: true,
                        label: 'Gebührenerhebung',
                        hint: 'Abschnitt für Gebühreninformationen',
                        child: ScaledText(
                          'Gebührenerhebung:',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                            fontWeight: FontWeight.bold,
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
          final updatedAntrag = BeduerfnisAntrag(
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
            vereinsnummer: antrag.vereinsnummer,
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
            statusId: BeduerfnisAntragStatus.entwurf.toId(),
            wbkNeu: _wbkType == 'neu',
            wbkArt: _wbkColor, // 'gelb' or 'gruen'
            beduerfnisart: beduerfnisartValue, // 'kurzwaffe' or 'langwaffe'
            anzahlWaffen: int.tryParse(_anzahlController.text) ?? 0,
            vereinsnummer: null,
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

  /// Proceeds to Step 2 or Step 5 depending on WBK type
  Future<void> _proceedToNextStep() async {
    if (!mounted) return;

    // Only save if there are changes
    if (_isDirty()) {
      await _saveAntrag();
    }

    // Get the antrag to pass to next step
    final antragForNext = widget.antrag ?? _createdAntrag;

    if (antragForNext == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte speichern Sie zuerst das Formular'),
          ),
        );
      }
      return;
    }

    // Fetch fresh antrag data from API to ensure we have the latest values
    final apiService = Provider.of<ApiService>(context, listen: false);
    final antragsList = await apiService.getBedAntragByAntragsnummer(
      antragForNext.antragsnummer!,
    );

    if (antragsList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden des Antrags')),
        );
      }
      return;
    }

    final freshAntrag = antragsList.first;
    const userRole = WorkflowRole.mitglied;

    // Always go to step 2
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BeduerfnisantragStep2Screen(
                userData: widget.userData,
                antrag: freshAntrag,
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
                userRole: userRole,
                readOnly: widget.readOnly,
              ),
        ),
      );
    }
  }
}
