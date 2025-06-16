// Project: Mein BSSB
// Filename: contact_data_screen.dart
// Author: Luis Mandel / NTT DATA

// Flutter/Dart core imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/contact.dart';
import '/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/widgets/scaled_text.dart';

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
  bool _isDeleting = false;
  bool _isAdding = false;
  final ScrollController _scrollController = ScrollController();

  // Use Contact model's type constants
  final Map<int, String> _contactTypeLabels = {
    for (var type in [1, 2, 3, 4, 5, 6, 7, 8])
      type: Contact(
        id: 0,
        personId: 0,
        type: type,
        value: '',
      ).typeLabel,
  };

  int? _selectedKontaktTyp;
  final TextEditingController _kontaktController = TextEditingController();

  // Regex for email validation
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  // Basic regex for phone numbers (allows digits, spaces, hyphens, plus sign, parentheses)
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

  // --- Contact Deletion Logic ---
  Future<void> _onDeleteContact(
    int kontaktId,
    int kontaktTyp,
    String contactValue,
    String contactLabel,
  ) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              'Kontaktdaten löschen',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIStyles.dialogContentStyle,
              children: <TextSpan>[
                const TextSpan(
                  text: 'Sind Sie sicher, dass Sie die Kontaktdaten ',
                ),
                TextSpan(
                  text: '$contactLabel: $contactValue',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' löschen möchten?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Abbrechen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.cancelButtonText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  UIConstants.horizontalSpacingM,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Löschen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.deleteButtonText,
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

    if (!mounted) return;

    if (confirmDelete == null || !confirmDelete) {
      LoggerService.logInfo('Contact deletion cancelled by user.');
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final contact = Contact(
        id: kontaktId,
        personId: widget.userData?.personId ?? 0,
        type: kontaktTyp,
        value: '', // Value is not needed for deletion
      );
      final bool success = await apiService.deleteKontakt(contact);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontaktdaten erfolgreich gelöscht.'),
              duration: Duration(seconds: 3),
            ),
          );
          _fetchContacts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Löschen der Kontaktdaten.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during contact deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ein Fehler ist aufgetreten: $e'),
            duration: const Duration(seconds: 3),
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

  // --- Add Contact Logic ---
  Future<void> _onAddContact() async {
    final String kontaktValue = _kontaktController.text.trim();

    if (_selectedKontaktTyp == null || kontaktValue.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte Kontakttyp und Kontaktwert eingeben.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Create a temporary Contact object for validation
    final contact = Contact(
      id: 0, // Temporary ID for new contact
      personId: widget.userData?.personId ?? 0,
      type: _selectedKontaktTyp!,
      value: kontaktValue,
    );

    // Input Validation based on Contact type
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.addKontakt(contact);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontaktdaten erfolgreich gespeichert.'),
              duration: Duration(seconds: 3),
            ),
          );
          _kontaktController.clear();
          _selectedKontaktTyp = null;
          _fetchContacts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Speichern der Kontaktdaten.'),
              duration: Duration(seconds: 3),
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  // --- Display Add Contact Form ---
  void _showAddContactForm() {
    _selectedKontaktTyp = null;
    _kontaktController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              'Neuen Kontakt hinzufügen',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<int>(
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'Kontakttyp',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  value: _selectedKontaktTyp,
                  items: _contactTypeLabels.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedKontaktTyp = newValue;
                    });
                  },
                ),
                const SizedBox(height: UIConstants.spacingM),
                TextFormField(
                  controller: _kontaktController,
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'Kontakt',
                    hintText: 'z.B. email@beispiel.de oder 0123 456789',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: UIConstants.closeIcon,
                          ),
                          const SizedBox(width: UIConstants.spacingS),
                          Text(
                            'Abbrechen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.cancelButtonText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: UIConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _onAddContact,
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: _isAdding
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.circularProgressIndicator,
                              ),
                              strokeWidth: 2,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: UIConstants.checkIcon,
                                  size: UIConstants.bodyFontSize + 4.0,
                                ),
                                const SizedBox(width: UIConstants.spacingS),
                                Text(
                                  'Hinzufügen',
                                  style:
                                      UIStyles.dialogButtonTextStyle.copyWith(
                                    color: UIConstants.submitButtonText,
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
  }

  // --- Logout Handler ---
  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactdataScreen');
    widget.onLogout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _kontaktController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Kontaktdaten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            LoggerService.logError(
              'Error loading contact data in FutureBuilder: ${snapshot.error}',
            );
            return Center(
              child: ScaledText(
                'Fehler beim Laden der Kontaktdaten: ${snapshot.error}',
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
              _isDeleting,
            );
          } else {
            return const Center(
              child: ScaledText('Keine Kontaktdaten gefunden.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactForm,
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContactTile({
    required int kontaktId,
    required int rawKontaktTyp,
    required String displayValue,
    required String displayLabel,
    required Function(int kontaktId, int kontaktTyp, String value, String label)
        onDelete,
    required bool isDeleting,
  }) {
    final displayValueFormatted = displayValue.isNotEmpty ? displayValue : '-';
    final displayLabelFormatted =
        displayLabel.isNotEmpty ? displayLabel : 'Unbekannt';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: UIConstants.spacingS,
      ),
      child: TextFormField(
        initialValue: displayValueFormatted,
        readOnly: true,
        style: UIStyles.formValueBoldStyle,
        decoration: UIStyles.formInputDecoration.copyWith(
          labelText: displayLabelFormatted,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: isDeleting ? null : displayLabelFormatted,
          fillColor: isDeleting ? UIConstants.disabledBackgroundColor : null,
          filled: isDeleting ? false : null,
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: UIConstants.deleteIcon,
            onPressed: isDeleting
                ? null
                : () => onDelete(
                      kontaktId,
                      rawKontaktTyp,
                      displayValue,
                      displayLabel,
                    ),
          ),
        ),
      ),
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
      child: Scrollbar(
        controller: _scrollController,
        thickness: 6,
        radius: const Radius.circular(8),
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
                  child: ScaledText(
                    categoryName,
                    style: UIStyles.subtitleStyle.copyWith(
                      color: UIConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: UIConstants.titleFontSize,
                    ),
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
                    isDeleting: isDeleting,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
