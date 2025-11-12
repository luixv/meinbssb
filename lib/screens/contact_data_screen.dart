import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/models/contact_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class ContactDataScreen extends StatefulWidget {
  const ContactDataScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  ContactDataScreenState createState() => ContactDataScreenState();
}

class ContactDataScreenState extends State<ContactDataScreen> {
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
  // Improved email regex: allows subdomains, plus, dash, underscore, etc.
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
  );
  final RegExp _phoneFaxMobileRegex = RegExp(r'^[0-9\s\-\+\(\)]+$');

  @override
  void initState() {
    super.initState();
    _fetchContacts();
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
        return data;
      });
      LoggerService.logInfo(
        'ContactDataScreen: Initiating contact data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      _contactDataFuture = Future.value([]);
    }
  }

  Future<void> _onDeleteContact(
    int kontaktId,
    int kontaktTyp,
    String contactValue,
    String contactLabel,
  ) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              Messages.contactDataDeleteTitle,
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: RichText(
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
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: UIStyles.dialogCancelButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, color: UIConstants.closeIcon),
                        UIConstants.horizontalSpacingS,
                        const Text('Abbrechen'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: UIStyles.dialogAcceptButtonStyle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: UIConstants.checkIcon),
                        UIConstants.horizontalSpacingS,
                        const Text('Löschen'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmDelete != true) {
      LoggerService.logInfo(
        'Contact deletion cancelled or widget not mounted.',
      );
      return;
    }

    // Show spinner immediately
    setState(() {
      _isDeleting = true;
    });

    LoggerService.logInfo('Starting contact deletion...');

    // Check network status and get API service
    final apiService = Provider.of<ApiService>(context, listen: false);
    final isOffline = !(await apiService.hasInternet());
    LoggerService.logInfo(
      'Network status: ${isOffline ? "offline" : "online"}',
    );
    
    if (!mounted) {
      LoggerService.logWarning('Widget not mounted after network check.');
      return;
    }
    
    if (isOffline) {
      LoggerService.logWarning('Cannot delete contact while offline.');
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontaktdaten können offline nicht gelöscht werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    try {
      // Perform deletion
      LoggerService.logInfo(
        'Calling deleteKontakt for contactId=$kontaktId, kontaktTyp=$kontaktTyp',
      );
      final contact = Contact(
        id: kontaktId,
        personId: widget.userData?.personId ?? 0,
        type: kontaktTyp,
        value: '',
      );
      final bool success = await apiService.deleteKontakt(contact);
      LoggerService.logInfo('deleteKontakt result: $success');

      if (!mounted) {
        LoggerService.logWarning('Widget not mounted after deleteKontakt.');
        return;
      }

      if (success) {
        LoggerService.logInfo('Contact deleted successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontaktdaten erfolgreich gelöscht.'),
            duration: UIConstants.snackbarDuration,
          ),
        );
        _fetchContacts();
      } else {
        LoggerService.logWarning('Failed to delete contact.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Löschen der Kontaktdaten.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      LoggerService.logError('Exception during contact deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
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

  Future<void> _onAddContact(BuildContext dialogContext) async {
    final String kontaktValue = _kontaktController.text.trim();

    if (_selectedKontaktTyp == null || kontaktValue.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte Kontakttyp und Kontaktwert eingeben.'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    final isOffline = !(await apiService.hasInternet());
    if (!mounted) return;
    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kontaktdaten können offline nicht hinzugefügt werden'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    final contact = Contact(
      id: 0,
      personId: widget.userData?.personId ?? 0,
      type: _selectedKontaktTyp!,
      value: kontaktValue,
    );

    String? validationErrorMessage;
    if (contact.isEmail) {
      if (!_emailRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
      }
    } else if (contact.isPhone || contact.isFax) {
      if (!_phoneFaxMobileRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige Telefon-/Faxnummer ein (nur Ziffern, +, -, (, ) erlaubt).';
      }
    }

    if (validationErrorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationErrorMessage),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
        setState(() {
          _isAdding = false;
        });
      }
      return;
    }

    try {
      // If it's an email contact, handle email validation flow
      if (contact.isEmail) {
        await _handleEmailValidation(contact, dialogContext);
      } else {
        // For non-email contacts, proceed with normal flow
        final bool success = await apiService.addKontakt(contact);

        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontaktdaten erfolgreich gespeichert.'),
              duration: UIConstants.snackbarDuration,
              backgroundColor: UIConstants.successColor,
            ),
          );
          _kontaktController.clear();
          _selectedKontaktTyp = null;
          _fetchContacts();
          Navigator.of(dialogContext).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Speichern der Kontaktdaten.'),
              duration: UIConstants.snackbarDuration,
              backgroundColor: UIConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during contact addition: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
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
    Contact contact,
    BuildContext dialogContext,
  ) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Generate verification token
      final verificationToken =
          apiService.authService.generateVerificationToken();

      // Determine email type
      final emailType = contact.type == 4 ? 'private' : 'business';

      // Create email validation entry in database
      await apiService.createEmailValidationEntry(
        personId: widget.userData!.personId.toString(),
        email: contact.value,
        emailType: emailType,
        verificationToken: verificationToken,
      );

      // Send validation email
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

      // Show success message in German
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte überprüfen Sie Ihre E-Mail, um Ihre neue E-Mail-Adresse zu bestätigen.',
          ),
          duration: UIConstants.snackbarDuration,
          backgroundColor: Colors.orange,
        ),
      );

      _kontaktController.clear();
      _selectedKontaktTyp = null;
      Navigator.of(dialogContext).pop();
    } catch (e) {
      LoggerService.logError('Exception during email validation setup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden der Bestätigungs-E-Mail: $e'),
            duration: UIConstants.snackbarDuration,
            backgroundColor: UIConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showAddContactForm() {
    _selectedKontaktTyp = null;
    _kontaktController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, child) {
                return AlertDialog(
                  backgroundColor: UIConstants.backgroundColor,
                  title: Center(
                    child: ScaledText(
                      'Neuen Kontakt hinzufügen',
                      style: UIStyles.dialogTitleStyle.copyWith(
                        fontSize:
                            UIStyles.dialogTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 20,
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: UIStyles.formInputDecoration
                                    .copyWith(
                                      labelText: 'Kontakttyp',
                                      labelStyle: UIStyles
                                          .formInputDecoration
                                          .labelStyle
                                          ?.copyWith(
                                            fontSize:
                                                UIStyles
                                                    .formInputDecoration
                                                    .labelStyle!
                                                    .fontSize! *
                                                fontSizeProvider.scaleFactor,
                                          ),
                                      floatingLabelStyle: UIStyles
                                          .formInputDecoration
                                          .floatingLabelStyle
                                          ?.copyWith(
                                            fontSize:
                                                UIStyles
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
                                items:
                                    _contactTypeLabels.entries.map((entry) {
                                      return DropdownMenuItem<int>(
                                        value: entry.key,
                                        child: ScaledText(
                                          entry.value,
                                          style: TextStyle(
                                            fontSize:
                                                UIConstants.subtitleFontSize *
                                                fontSizeProvider.scaleFactor,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (int? newValue) {
                                  setStateDialog(() {
                                    _selectedKontaktTyp = newValue;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        TextFormField(
                          controller: _kontaktController,
                          decoration: UIStyles.formInputDecoration.copyWith(
                            labelText: 'Kontakt',
                            labelStyle: UIStyles.formInputDecoration.labelStyle
                                ?.copyWith(
                                  fontSize:
                                      UIStyles
                                          .formInputDecoration
                                          .labelStyle!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                            floatingLabelStyle: UIStyles
                                .formInputDecoration
                                .floatingLabelStyle
                                ?.copyWith(
                                  fontSize:
                                      UIStyles
                                          .formInputDecoration
                                          .floatingLabelStyle!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                            hintText: 'z.B. email@beispiel.de oder 0123 456789',
                            hintStyle: UIStyles.formInputDecoration.hintStyle
                                ?.copyWith(
                                  fontSize:
                                      UIStyles
                                          .formInputDecoration
                                          .hintStyle!
                                          .fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                          style: TextStyle(
                            fontSize:
                                UIConstants.subtitleFontSize *
                                fontSizeProvider.scaleFactor,
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ],
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
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 40),
                            child: ElevatedButton(
                              onPressed:
                                  _isAdding
                                      ? null
                                      : () => Navigator.of(dialogContext).pop(),
                              style: UIStyles.dialogCancelButtonStyle.copyWith(
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
                                  ),
                                  const SizedBox(width: UIConstants.spacingS),
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
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 40),
                            child: ElevatedButton(
                              onPressed:
                                  _isAdding || _selectedKontaktTyp == null
                                      ? null
                                      : () async {
                                        setStateDialog(() => _isAdding = true);
                                        await _onAddContact(dialogContext);
                                      },
                              style: UIStyles.dialogAcceptButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    vertical: UIConstants.spacingS,
                                  ),
                                ),
                              ),
                              child:
                                  _isAdding
                                      ? const SizedBox(
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
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: UIConstants.checkIcon,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Hinzufügen',
                                            style: UIStyles
                                                .dialogButtonTextStyle
                                                .copyWith(
                                                  color:
                                                      UIConstants
                                                          .submitButtonText,
                                                  fontSize:
                                                      UIConstants
                                                          .buttonFontSize,
                                                ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactdataScreen');
    widget.onLogout();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _kontaktController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BaseScreenLayout(
          title: 'Kontaktdaten',
          userData: widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: _handleLogout,
          body: Semantics(
            label:
                'Kontaktdatenbereich. Hier können Sie Ihre gespeicherten Kontakte einsehen, hinzufügen und löschen.',
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _contactDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  LoggerService.logError(
                    'Error loading contact data in FutureBuilder:  [${snapshot.error}',
                  );
                  return Center(
                    child: ScaledText(
                      'Fehler beim Laden der Kontaktdaten:  [${snapshot.error}',
                      style: UIStyles.errorStyle,
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final List<Map<String, dynamic>> categorizedContactData =
                      snapshot.data!;
                  return _buildContactDataList(
                    categorizedContactData,
                    widget.userData?.personId ?? 0,
                    _onDeleteContact,
                    false,
                  );
                } else {
                  return const Center(
                    child: ScaledText('Keine Kontaktdaten gefunden.'),
                  );
                }
              },
            ),
          ),
          floatingActionButton: _AddContactButton(
            onPressed: _showAddContactForm,
          ),
        ),
        // Whole-screen overlay spinner for deletion
        if (_isDeleting)
          Positioned.fill(
            child: Container(
              color: UIConstants.textColor.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    UIConstants.circularProgressIndicator,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactTile({
    required int kontaktId,
    required int rawKontaktTyp,
    required String displayValue,
    required String displayLabel,
    required Function(int kontaktId, int kontaktTyp, String value, String label)
    onDelete,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return _ContactTileWithKeyboardFocus(
          displayValue: displayValue,
          displayLabel: displayLabel,
          kontaktId: kontaktId,
          rawKontaktTyp: rawKontaktTyp,
          onDelete: onDelete,
          fontSizeProvider: fontSizeProvider,
        );
      },
    );
  }

  Widget _buildContactDataList(
    List<Map<String, dynamic>> contactData,
    int personId,
    Function(int kontaktId, int kontaktTyp, String value, String label)
    onDelete,
    bool isDeleting,
  ) {
    return Padding(
      padding: UIConstants.defaultPadding,
      child: Column(
        children: [
          Expanded(
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.spacingS,
                        ),
                        child: Consumer<FontSizeProvider>(
                          builder: (context, fontSizeProvider, child) {
                            return ScaledText(
                              categoryName,
                              style: UIStyles.subtitleStyle.copyWith(
                                color: UIConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    UIConstants.titleFontSize *
                                    fontSizeProvider.scaleFactor,
                              ),
                            );
                          },
                        ),
                      ),
                      ...contacts.map((contact) {
                        final kontaktId = contact['kontaktId'] as int;
                        final rawKontaktTyp = contact['rawKontaktTyp'] as int;
                        final displayValue = contact['value'] as String;
                        final displayLabel = contact['type'] as String;

                        return _buildContactTile(
                          kontaktId: kontaktId,
                          rawKontaktTyp: rawKontaktTyp,
                          displayValue: displayValue,
                          displayLabel: displayLabel,
                          onDelete: onDelete,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: UIConstants.spacingXXXL),
        ],
      ),
    );
  }
}

// Custom Contact Tile with keyboard-only focus highlighting
class _ContactTileWithKeyboardFocus extends StatefulWidget {
  const _ContactTileWithKeyboardFocus({
    required this.displayValue,
    required this.displayLabel,
    required this.kontaktId,
    required this.rawKontaktTyp,
    required this.onDelete,
    required this.fontSizeProvider,
  });

  final String displayValue;
  final String displayLabel;
  final int kontaktId;
  final int rawKontaktTyp;
  final Function(int kontaktId, int kontaktTyp, String value, String label) onDelete;
  final FontSizeProvider fontSizeProvider;

  @override
  State<_ContactTileWithKeyboardFocus> createState() => _ContactTileWithKeyboardFocusState();
}

class _ContactTileWithKeyboardFocusState extends State<_ContactTileWithKeyboardFocus> {
  bool _hasKeyboardFocus = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (highlighted) {
        setState(() {
          _hasKeyboardFocus = highlighted;
        });
      },
      child: Semantics(
        label: 'Kontaktfeld: ${widget.displayLabel}',
        hint: 'Gespeicherter Wert: ${widget.displayValue}. Löschen mit Button rechts.',
        textField: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
          child: TextFormField(
            initialValue: widget.displayValue.isNotEmpty ? widget.displayValue : '-',
            readOnly: true,
            style: UIStyles.formValueBoldStyle.copyWith(
              fontSize:
                  UIStyles.formValueBoldStyle.fontSize! *
                  widget.fontSizeProvider.scaleFactor,
            ),
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: widget.displayLabel.isNotEmpty ? widget.displayLabel : 'Unbekannt',
              fillColor: _hasKeyboardFocus ? Colors.yellow.shade100 : null,
              focusedBorder: _hasKeyboardFocus
                  ? OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.yellow.shade700,
                      width: 2.0,
                    ),
                  )
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: UIConstants.iconSizeS * widget.fontSizeProvider.scaleFactor,
                ),
                tooltip: 'Löschen',
                color: UIConstants.deleteIcon,
                onPressed: () => widget.onDelete(
                  widget.kontaktId,
                  widget.rawKontaktTyp,
                  widget.displayValue,
                  widget.displayLabel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Add Contact Button widget with hover and focus support
class _AddContactButton extends StatefulWidget {
  const _AddContactButton({required this.onPressed});
  
  final VoidCallback onPressed;

  @override
  State<_AddContactButton> createState() => _AddContactButtonState();
}

class _AddContactButtonState extends State<_AddContactButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = (_isHovered || _isFocused) 
        ? Colors.black 
        : UIConstants.defaultAppColor;

    return Semantics(
      label: 'Kontakt hinzufügen',
      hint: 'Tippen, um einen neuen Kontakt hinzuzufügen',
      button: true,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: FloatingActionButton(
            heroTag: 'contactDataFab',
            onPressed: widget.onPressed,
            backgroundColor: backgroundColor,
            child: const Icon(Icons.add, color: UIConstants.whiteColor),
          ),
        ),
      ),
    );
  }
}
