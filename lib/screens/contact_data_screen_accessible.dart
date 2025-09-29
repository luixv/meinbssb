// Project: Mein BSSB
// Filename: contact_data_screen_accessible.dart
// Author: Luis Mandel / NTT DATA
// BITV 2.0 konforme Version der Kontaktdaten-Verwaltung

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/models/contact_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/base_screen_layout_accessible.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

/// BITV 2.0 konforme Version der Kontaktdaten-Verwaltung
///
/// Diese Klasse implementiert umfassende Barrierefreiheit für die
/// Kontaktdaten-Verwaltung gemäß BITV 2.0 / WCAG 2.1 Level AA.
///
/// Accessibility Features:
/// - 25+ Semantics widgets für strukturelle Kennzeichnung
/// - 15+ SemanticsService announcements für automatische Ansagen
/// - Semantische Liste-Struktur für Kontakt-Kategorien
/// - Live-Validierung mit direktem Feedback
/// - Zugängliche Dialoge mit Fokus-Verwaltung
/// - Automatische Status-Ankündigungen für CRUD-Operationen
/// - Strukturierte Überschriften für Kategorien
/// - Zugängliche Loading-States mit Abbrechen-Option
/// - Deutsche Sprachunterstützung mit semantischen Labels
/// - Barrierefreie Button-Beschriftungen und Tooltips
class ContactDataScreenAccessible extends StatefulWidget {
  const ContactDataScreenAccessible(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  ContactDataScreenAccessibleState createState() =>
      ContactDataScreenAccessibleState();
}

class ContactDataScreenAccessibleState
    extends State<ContactDataScreenAccessible> {
  late Future<List<Map<String, dynamic>>> _contactDataFuture;
  bool _isAdding = false;
  bool _isDeleting = false;
  final ScrollController _scrollController = ScrollController();

  final Map<int, String> _contactTypeLabels = {
    for (var type in [1, 2, 3, 4, 5, 6, 7, 8])
      type: Contact(id: 0, personId: 0, type: type, value: '').typeLabel,
  };

  int? _selectedKontaktTyp;
  final TextEditingController _kontaktController = TextEditingController();
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  final RegExp _phoneFaxMobileRegex = RegExp(r'^[0-9\s\-\+\(\)]+$');

  String? _validationError;
  final FocusNode _contactTypeFocusNode = FocusNode();
  final FocusNode _contactValueFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchContacts();

    // Initiale Ankündigung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Kontaktdaten-Verwaltung geladen. ${_contactTypeLabels.length} Kontakttypen verfügbar.',
        TextDirection.ltr,
      );
    });
  }

  Future<void> _fetchContacts() async {
    final int personId = widget.userData?.personId ?? 0;
    setState(() {
      _contactDataFuture = Future.value([]);
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _contactDataFuture = apiService.fetchKontakte(personId).then((data) {
        LoggerService.logInfo('Contact data structure: $data');

        // Ankündigung der geladenen Kontakte
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SemanticsService.announce(
            'Kontaktdaten aktualisiert. ${data.length} Kategorien mit Kontakten gefunden.',
            TextDirection.ltr,
          );
        });

        return data;
      });
      LoggerService.logInfo(
          'ContactDataScreen: Initiating contact data fetch.',);
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      _contactDataFuture = Future.value([]);

      // Fehler-Ankündigung
      SemanticsService.announce(
        'Fehler beim Laden der Kontaktdaten: $e',
        TextDirection.ltr,
      );
    }
  }

  /// Validiert Kontaktwert basierend auf ausgewähltem Typ
  String? _validateContactValue(String value, int? contactType) {
    if (value.isEmpty) return null;

    if (contactType == 4 || contactType == 5) {
      // E-Mail
      if (!_emailRegex.hasMatch(value)) {
        return 'Ungültige E-Mail-Adresse eingegeben';
      }
    } else if (contactType == 1 || contactType == 2 || contactType == 3) {
      // Telefon/Fax
      if (!_phoneFaxMobileRegex.hasMatch(value)) {
        return 'Ungültige Telefonnummer eingegeben';
      }
    }
    return null;
  }

  Future<void> _onDeleteContact(
    int kontaktId,
    int kontaktTyp,
    String contactValue,
    String contactLabel,
  ) async {
    bool? confirmDelete = await _showAccessibleDeleteDialog(
      contactValue,
      contactLabel,
    );

    if (!mounted || confirmDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    // Ankündigung vor Löschvorgang
    SemanticsService.announce(
      'Kontakt $contactLabel wird gelöscht',
      TextDirection.ltr,
    );

    final navigator = Navigator.of(context);

    // Zugänglicher Loading-Dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _buildAccessibleLoadingDialog(
          'Kontakt wird gelöscht...',
          'Kontakt $contactLabel wird gelöscht, bitte warten',
        );
      },
    );

    try {
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      final isOffline = !(await networkService.hasInternet());
      if (!mounted) return;

      if (isOffline) {
        navigator.pop();
        _showAccessibleSnackBar(
          'Kontaktdaten können offline nicht gelöscht werden',
          isError: true,
        );
        return;
      }

      final apiService = Provider.of<ApiService>(context, listen: false);
      final contact = Contact(
        id: kontaktId,
        personId: widget.userData?.personId ?? 0,
        type: kontaktTyp,
        value: '',
      );
      final bool success = await apiService.deleteKontakt(contact);

      if (!mounted) return;
      navigator.pop();

      if (success) {
        _showAccessibleSnackBar('Kontaktdaten erfolgreich gelöscht.');

        // Erfolgs-Ankündigung
        SemanticsService.announce(
          'Erfolgreich: Kontakt $contactLabel mit Wert $contactValue wurde gelöscht',
          TextDirection.ltr,
        );

        _fetchContacts();
      } else {
        _showAccessibleSnackBar(
          'Fehler beim Löschen der Kontaktdaten.',
          isError: true,
        );

        // Fehler-Ankündigung
        SemanticsService.announce(
          'Fehler: Kontakt $contactLabel konnte nicht gelöscht werden',
          TextDirection.ltr,
        );
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        _showAccessibleSnackBar(
          'Ein Fehler ist aufgetreten: $e',
          isError: true,
        );

        SemanticsService.announce(
          'Unerwarteter Fehler beim Löschen: $e',
          TextDirection.ltr,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  /// Zeigt zugänglichen Lösch-Bestätigungsdialog
  Future<bool?> _showAccessibleDeleteDialog(
      String contactValue, String contactLabel,) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          label: 'Bestätigungsdialog: Kontakt löschen',
          child: AlertDialog(
            backgroundColor: UIConstants.backgroundColor,
            title: Semantics(
              header: true,
              label: 'Dialog-Überschrift: Kontakt löschen',
              child: const Center(
                child: Text(
                  Messages.contactDataDeleteTitle,
                  style: UIStyles.dialogTitleStyle,
                ),
              ),
            ),
            content: Semantics(
              readOnly: true,
              label: 'Bestätigungsfrage mit Kontaktdetails',
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: UIStyles.dialogContentStyle,
                  children: <TextSpan>[
                    const TextSpan(text: Messages.contactDataDeleteQuestion),
                    TextSpan(
                      text: '\n\n$contactLabel: $contactValue',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '\n\nlöschen möchten?'),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingM,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Abbrechen-Button
                    Semantics(
                      button: true,
                      label: 'Abbrechen',
                      hint: 'Schließt Dialog ohne Löschen des Kontakts',
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: UIStyles.dialogCancelButtonStyle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.close,
                              color: UIConstants.closeIcon,
                              semanticLabel: 'Schließen-Symbol',
                            ),
                            UIConstants.horizontalSpacingS,
                            const Text('Abbrechen'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Löschen-Button
                    Semantics(
                      button: true,
                      label: 'Kontakt endgültig löschen',
                      hint:
                          'Löscht $contactLabel: $contactValue unwiderruflich',
                      child: ElevatedButton(
                        onPressed: () {
                          // Ankündigung vor Bestätigung
                          SemanticsService.announce(
                            'Löschvorgang wird bestätigt',
                            TextDirection.ltr,
                          );
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: UIStyles.dialogAcceptButtonStyle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check,
                              color: UIConstants.checkIcon,
                              semanticLabel: 'Bestätigen-Symbol',
                            ),
                            UIConstants.horizontalSpacingS,
                            const Text('Löschen'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Baut zugänglichen Loading-Dialog
  Widget _buildAccessibleLoadingDialog(String title, String description) {
    return Semantics(
      label: 'Ladedialog: $title',
      hint: '$description. Dialog kann durch Zurück-Taste geschlossen werden.',
      child: AlertDialog(
        backgroundColor: UIConstants.backgroundColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Ladeindikator',
              hint: description,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  UIConstants.circularProgressIndicator,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Semantics(
              liveRegion: true,
              label: 'Status-Nachricht',
              child: Text(
                title,
                style: UIStyles.dialogContentStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Semantics(
              button: true,
              label: 'Vorgang abbrechen',
              hint: 'Schließt Ladedialog und bricht Vorgang ab',
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zeigt zugängliche SnackBar mit automatischer Ankündigung
  void _showAccessibleSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: UIConstants.snackbarDuration,
        backgroundColor: isError ? UIConstants.errorColor : null,
      ),
    );

    // Zusätzliche semantische Ankündigung
    SemanticsService.announce(
      isError ? 'Fehler: $message' : 'Hinweis: $message',
      TextDirection.ltr,
    );
  }

  Future<void> _onAddContact(BuildContext dialogContext) async {
    final String kontaktValue = _kontaktController.text.trim();

    if (_selectedKontaktTyp == null || kontaktValue.isEmpty) {
      _showAccessibleSnackBar(
        'Bitte Kontakttyp und Kontaktwert eingeben.',
        isError: true,
      );
      return;
    }

    // Validierung mit Live-Feedback
    final validationError =
        _validateContactValue(kontaktValue, _selectedKontaktTyp);
    if (validationError != null) {
      _showAccessibleSnackBar(validationError, isError: true);
      return;
    }

    setState(() {
      _isAdding = true;
    });

    // Ankündigung vor Hinzufügen
    SemanticsService.announce(
      'Neuer Kontakt wird hinzugefügt: ${_contactTypeLabels[_selectedKontaktTyp!]} - $kontaktValue',
      TextDirection.ltr,
    );

    final networkService = Provider.of<NetworkService>(context, listen: false);
    final isOffline = !(await networkService.hasInternet());
    if (!mounted) return;

    if (isOffline) {
      _showAccessibleSnackBar(
        'Kontaktdaten können offline nicht hinzugefügt werden',
        isError: true,
      );
      setState(() {
        _isAdding = false;
      });
      return;
    }

    final contact = Contact(
      id: 0,
      personId: widget.userData?.personId ?? 0,
      type: _selectedKontaktTyp!,
      value: kontaktValue,
    );

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (contact.isEmail) {
        await _handleEmailValidation(contact, dialogContext);
      } else {
        final bool success = await apiService.addKontakt(contact);

        if (!mounted) return;
        if (success) {
          _showAccessibleSnackBar('Kontaktdaten erfolgreich gespeichert.');

          // Erfolgs-Ankündigung
          SemanticsService.announce(
            'Erfolgreich: Neuer Kontakt ${_contactTypeLabels[_selectedKontaktTyp!]} wurde hinzugefügt',
            TextDirection.ltr,
          );

          _kontaktController.clear();
          _selectedKontaktTyp = null;
          _validationError = null;
          _fetchContacts();
          Navigator.of(dialogContext).pop();
        } else {
          _showAccessibleSnackBar(
            'Fehler beim Speichern der Kontaktdaten.',
            isError: true,
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during contact addition: $e');
      if (mounted) {
        _showAccessibleSnackBar(
          'Ein Fehler ist aufgetreten: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  Future<void> _handleEmailValidation(
      Contact contact, BuildContext dialogContext,) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final verificationToken = authService.generateVerificationToken();
      final emailType = contact.type == 4 ? 'private' : 'business';

      await apiService.createEmailValidationEntry(
        personId: widget.userData!.personId.toString(),
        email: contact.value,
        emailType: emailType,
        verificationToken: verificationToken,
      );

      await apiService.sendEmailValidationNotifications(
        personId: widget.userData!.personId.toString(),
        email: contact.value,
        firstName: widget.userData!.vorname,
        lastName: widget.userData!.namen,
        title: widget.userData!.titel ?? '',
        emailType: emailType,
        verificationToken: verificationToken,
      );

      if (!mounted) return;

      _showAccessibleSnackBar(
        'Bitte überprüfen Sie Ihre E-Mail, um Ihre neue E-Mail-Adresse zu bestätigen.',
        isError: false,
      );

      // E-Mail-Validierung Ankündigung
      SemanticsService.announce(
        'E-Mail-Bestätigung versendet: Überprüfen Sie Ihr Postfach für ${contact.value}',
        TextDirection.ltr,
      );

      _kontaktController.clear();
      _selectedKontaktTyp = null;
      _validationError = null;
      Navigator.of(dialogContext).pop();
    } catch (e) {
      LoggerService.logError('Exception during email validation setup: $e');
      if (mounted) {
        _showAccessibleSnackBar(
          'Fehler beim Senden der Bestätigungs-E-Mail: $e',
          isError: true,
        );
      }
    }
  }

  void _showAddContactForm() {
    _selectedKontaktTyp = null;
    _kontaktController.clear();
    _validationError = null;

    // Ankündigung vor Dialog-Öffnung
    SemanticsService.announce(
      'Dialog zum Hinzufügen eines neuen Kontakts wird geöffnet',
      TextDirection.ltr,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, child) {
                return Semantics(
                  scopesRoute: true,
                  explicitChildNodes: true,
                  label: 'Dialog: Neuen Kontakt hinzufügen',
                  child: AlertDialog(
                    backgroundColor: UIConstants.backgroundColor,
                    title: Semantics(
                      header: true,
                      label: 'Dialog-Überschrift',
                      child: Center(
                        child: ScaledText(
                          'Neuen Kontakt hinzufügen',
                          style: UIStyles.dialogTitleStyle.copyWith(
                            fontSize: UIStyles.dialogTitleStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    content: Semantics(
                      label: 'Formular zum Eingeben der Kontaktdaten',
                      child: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            // Kontakttyp-Dropdown
                            Semantics(
                              label: 'Kontakttyp auswählen',
                              hint:
                                  'Dropdown-Menü mit ${_contactTypeLabels.length} verfügbaren Kontakttypen',
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      focusNode: _contactTypeFocusNode,
                                      decoration:
                                          UIStyles.formInputDecoration.copyWith(
                                        labelText: 'Kontakttyp *',
                                        labelStyle: UIStyles
                                            .formInputDecoration.labelStyle
                                            ?.copyWith(
                                          fontSize: UIStyles.formInputDecoration
                                                  .labelStyle!.fontSize! *
                                              fontSizeProvider.scaleFactor,
                                        ),
                                        floatingLabelStyle: UIStyles
                                            .formInputDecoration
                                            .floatingLabelStyle
                                            ?.copyWith(
                                          fontSize: UIStyles
                                                  .formInputDecoration
                                                  .floatingLabelStyle!
                                                  .fontSize! *
                                              fontSizeProvider.scaleFactor,
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.auto,
                                      ),
                                      value: _selectedKontaktTyp,
                                      isExpanded: true,
                                      items: _contactTypeLabels.entries
                                          .map((entry) {
                                        return DropdownMenuItem<int>(
                                          value: entry.key,
                                          child: Semantics(
                                            label:
                                                'Kontakttyp-Option: ${entry.value}',
                                            child: ScaledText(
                                              entry.value,
                                              style: TextStyle(
                                                fontSize: UIConstants
                                                        .subtitleFontSize *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        setStateDialog(() {
                                          _selectedKontaktTyp = newValue;
                                          // Validierung bei Typ-Änderung
                                          _validationError =
                                              _validateContactValue(
                                            _kontaktController.text.trim(),
                                            newValue,
                                          );
                                        });

                                        if (newValue != null) {
                                          SemanticsService.announce(
                                            'Kontakttyp ausgewählt: ${_contactTypeLabels[newValue]}',
                                            TextDirection.ltr,
                                          );

                                          // Fokus auf Eingabefeld setzen
                                          _contactValueFocusNode.requestFocus();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingM),

                            // Kontakt-Eingabefeld mit Live-Validierung
                            Semantics(
                              textField: true,
                              label: 'Kontaktwert eingeben',
                              hint:
                                  'z.B. E-Mail-Adresse oder Telefonnummer je nach ausgewähltem Typ',
                              child: TextFormField(
                                controller: _kontaktController,
                                focusNode: _contactValueFocusNode,
                                decoration:
                                    UIStyles.formInputDecoration.copyWith(
                                  labelText: 'Kontakt *',
                                  labelStyle: UIStyles
                                      .formInputDecoration.labelStyle
                                      ?.copyWith(
                                    fontSize: UIStyles.formInputDecoration
                                            .labelStyle!.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  floatingLabelStyle: UIStyles
                                      .formInputDecoration.floatingLabelStyle
                                      ?.copyWith(
                                    fontSize: UIStyles.formInputDecoration
                                            .floatingLabelStyle!.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  hintText:
                                      'z.B. email@beispiel.de oder 0123 456789',
                                  hintStyle: UIStyles
                                      .formInputDecoration.hintStyle
                                      ?.copyWith(
                                    fontSize: UIStyles.formInputDecoration
                                            .hintStyle!.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                  errorText: _validationError,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.auto,
                                ),
                                style: TextStyle(
                                  fontSize: UIConstants.subtitleFontSize *
                                      fontSizeProvider.scaleFactor,
                                ),
                                keyboardType: TextInputType.text,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    _validationError = _validateContactValue(
                                      value.trim(),
                                      _selectedKontaktTyp,
                                    );
                                  });

                                  // Live-Validierung Ankündigung
                                  if (_validationError != null) {
                                    SemanticsService.announce(
                                      'Eingabefehler: $_validationError',
                                      TextDirection.ltr,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingM,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Abbrechen-Button
                            Semantics(
                              button: true,
                              label: 'Abbrechen',
                              hint:
                                  'Schließt Dialog ohne Speichern des neuen Kontakts',
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 40),
                                child: ElevatedButton(
                                  onPressed: _isAdding
                                      ? null
                                      : () {
                                          SemanticsService.announce(
                                            'Dialog wird geschlossen ohne Speichern',
                                            TextDirection.ltr,
                                          );
                                          Navigator.of(dialogContext).pop();
                                        },
                                  style:
                                      UIStyles.dialogCancelButtonStyle.copyWith(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        horizontal: UIConstants.spacingM,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.close,
                                        color: UIConstants.closeIcon,
                                        size: UIConstants.defaultIconSize,
                                        semanticLabel: 'Schließen-Symbol',
                                      ),
                                      const SizedBox(
                                          width: UIConstants.spacingS,),
                                      Text(
                                        'Abbrechen',
                                        style: UIStyles.dialogButtonTextStyle
                                            .copyWith(
                                          color: UIConstants.cancelButtonText,
                                          fontSize: UIConstants.buttonFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Hinzufügen-Button
                            Semantics(
                              button: true,
                              label: _isAdding
                                  ? 'Kontakt wird hinzugefügt...'
                                  : 'Neuen Kontakt hinzufügen',
                              hint: _isAdding
                                  ? 'Vorgang läuft, bitte warten'
                                  : 'Speichert den neuen Kontakt mit den eingegebenen Daten',
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 40),
                                child: ElevatedButton(
                                  onPressed: (_isAdding ||
                                          _validationError != null)
                                      ? null
                                      : () async {
                                          setStateDialog(
                                              () => _isAdding = true,);
                                          await _onAddContact(dialogContext);
                                        },
                                  style:
                                      UIStyles.dialogAcceptButtonStyle.copyWith(
                                    padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        vertical: UIConstants.spacingS,
                                      ),
                                    ),
                                  ),
                                  child: _isAdding
                                      ? Semantics(
                                          label:
                                              'Ladeindikator: Kontakt wird gespeichert',
                                          child: const SizedBox(
                                            width: UIConstants.defaultIconSize,
                                            height: UIConstants.defaultIconSize,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                UIConstants
                                                    .circularProgressIndicator,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.check,
                                              color: UIConstants.checkIcon,
                                              size: 20,
                                              semanticLabel:
                                                  'Bestätigen-Symbol',
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Hinzufügen',
                                              style: UIStyles
                                                  .dialogButtonTextStyle
                                                  .copyWith(
                                                color: UIConstants
                                                    .submitButtonText,
                                                fontSize: 14,
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
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactDataScreenAccessible');
    SemanticsService.announce(
      'Benutzer wird abgemeldet',
      TextDirection.ltr,
    );
    widget.onLogout();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _kontaktController.dispose();
    _contactTypeFocusNode.dispose();
    _contactValueFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayoutAccessible(
      title: 'Kontaktdaten verwalten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: _buildAccessibleBody(),
      floatingActionButton: _buildAccessibleFAB(),
    );
  }

  /// Baut den barrierefreien Hauptinhalt
  Widget _buildAccessibleBody() {
    return Semantics(
      label: 'Kontaktdaten-Verwaltung Hauptbereich',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Semantics(
              label: 'Kontaktdaten werden geladen',
              hint: 'Bitte warten, während die Kontaktdaten abgerufen werden',
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            LoggerService.logError(
              'Error loading contact data in FutureBuilder: [${snapshot.error}',
            );
            return Semantics(
              label: 'Fehler beim Laden der Kontaktdaten',
              child: Center(
                child: ScaledText(
                  'Fehler beim Laden der Kontaktdaten: [${snapshot.error}',
                  style: UIStyles.errorStyle,
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<Map<String, dynamic>> categorizedContactData =
                snapshot.data!;
            return _buildAccessibleContactDataList(categorizedContactData);
          } else {
            return Semantics(
              label: 'Keine Kontaktdaten vorhanden',
              hint:
                  'Es wurden keine Kontakte gefunden. Verwenden Sie den Plus-Button zum Hinzufügen.',
              child: const Center(
                child: ScaledText('Keine Kontaktdaten gefunden.'),
              ),
            );
          }
        },
      ),
    );
  }

  /// Baut die barrierefreie Kontaktliste
  Widget _buildAccessibleContactDataList(
      List<Map<String, dynamic>> contactData,) {
    return Semantics(
      label: 'Kontaktdaten-Liste mit ${contactData.length} Kategorien',
      hint:
          'Scrollbare Liste. Jede Kategorie enthält Kontakte mit Löschoptionen.',
      child: Padding(
        padding: UIConstants.defaultPadding,
        child: Column(
          children: [
            Expanded(
              child: Semantics(
                label: 'Scrollbare Kontakt-Kategorien',
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: UIConstants.dividerThick,
                  radius: const Radius.circular(UIConstants.cornerRadius),
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: contactData.length,
                    itemBuilder: (context, index) {
                      final category = contactData[index];
                      final contacts = category['contacts'] as List<dynamic>;
                      final categoryName = category['category'] as String;

                      return _buildAccessibleCategorySection(
                        categoryName,
                        contacts,
                        index,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingXXXL),
          ],
        ),
      ),
    );
  }

  /// Baut eine barrierefreie Kategorie-Sektion
  Widget _buildAccessibleCategorySection(
    String categoryName,
    List<dynamic> contacts,
    int categoryIndex,
  ) {
    return Semantics(
      container: true,
      label: 'Kategorie $categoryIndex: $categoryName',
      hint: '${contacts.length} Kontakte in dieser Kategorie',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategorie-Überschrift
          Semantics(
            header: true,
            label: 'Kategorie-Überschrift: $categoryName',
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: UIConstants.spacingS),
              child: Consumer<FontSizeProvider>(
                builder: (context, fontSizeProvider, child) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingM,
                      vertical: UIConstants.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: UIConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      border: const Border(
                        left: BorderSide(
                          width: 4.0,
                          color: UIConstants.primaryColor,
                        ),
                      ),
                    ),
                    child: ScaledText(
                      categoryName,
                      style: UIStyles.subtitleStyle.copyWith(
                        color: UIConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: UIConstants.titleFontSize *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Kontakt-Liste
          Semantics(
            label: 'Kontakte in Kategorie $categoryName',
            child: Column(
              children: contacts.asMap().entries.map((entry) {
                final contactIndex = entry.key;
                final contact = entry.value;
                final kontaktId = contact['kontaktId'] as int;
                final rawKontaktTyp = contact['rawKontaktTyp'] as int;
                final displayValue = contact['value'] as String;
                final displayLabel = contact['type'] as String;

                return _buildAccessibleContactTile(
                  kontaktId: kontaktId,
                  rawKontaktTyp: rawKontaktTyp,
                  displayValue: displayValue,
                  displayLabel: displayLabel,
                  contactIndex: contactIndex,
                  totalInCategory: contacts.length,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Baut eine barrierefreie Kontakt-Kachel
  Widget _buildAccessibleContactTile({
    required int kontaktId,
    required int rawKontaktTyp,
    required String displayValue,
    required String displayLabel,
    required int contactIndex,
    required int totalInCategory,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          label:
              'Kontakt ${contactIndex + 1} von $totalInCategory: $displayLabel',
          hint:
              'Wert: ${displayValue.isNotEmpty ? displayValue : "Kein Wert"}. Löschen-Button verfügbar.',
          child: Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
            child: Row(
              children: [
                // Kontakt-Informationen
                Expanded(
                  child: Semantics(
                    readOnly: true,
                    label:
                        '$displayLabel: ${displayValue.isNotEmpty ? displayValue : "Kein Wert"}',
                    hint: 'Schreibgeschütztes Kontaktfeld',
                    child: TextFormField(
                      initialValue:
                          displayValue.isNotEmpty ? displayValue : '-',
                      readOnly: true,
                      style: UIStyles.formValueBoldStyle.copyWith(
                        fontSize: UIStyles.formValueBoldStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: displayLabel.isNotEmpty
                            ? displayLabel
                            : 'Unbekannt',
                      ),
                    ),
                  ),
                ),

                // Löschen-Button
                Semantics(
                  button: true,
                  label: '$displayLabel löschen',
                  hint:
                      'Löscht den Kontakt ${displayValue.isNotEmpty ? displayValue : "ohne Wert"} unwiderruflich',
                  excludeSemantics: true,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size:
                          UIConstants.iconSizeS * fontSizeProvider.scaleFactor,
                      semanticLabel: 'Löschen-Symbol',
                    ),
                    color: UIConstants.deleteIcon,
                    tooltip: '$displayLabel löschen',
                    onPressed: _isDeleting
                        ? null
                        : () => _onDeleteContact(
                              kontaktId,
                              rawKontaktTyp,
                              displayValue,
                              displayLabel,
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

  /// Baut den barrierefreien Floating Action Button
  Widget _buildAccessibleFAB() {
    return Semantics(
      button: true,
      label: 'Neuen Kontakt hinzufügen',
      hint:
          'Öffnet Dialog zum Hinzufügen eines neuen Kontakts mit Typ und Wert',
      child: FloatingActionButton(
        heroTag: 'contactDataFabAccessible',
        onPressed: () {
          SemanticsService.announce(
            'Dialog zum Hinzufügen eines neuen Kontakts wird geöffnet',
            TextDirection.ltr,
          );
          _showAddContactForm();
        },
        backgroundColor: UIConstants.defaultAppColor,
        tooltip: 'Neuen Kontakt hinzufügen',
        child: const Icon(
          Icons.add,
          color: UIConstants.whiteColor,
          semanticLabel: 'Plus-Symbol zum Hinzufügen',
        ),
      ),
    );
  }
}
