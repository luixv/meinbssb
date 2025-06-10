// In lib/screens/contact_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/api_service.dart';
import '../services/core/logger_service.dart';

class ContactDataScreen extends StatefulWidget {
  const ContactDataScreen(
    this.userData, {
    required this.personId,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final Map<String, dynamic> userData;
  final int personId;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  ContactDataScreenState createState() => ContactDataScreenState();
}

class ContactDataScreenState extends State<ContactDataScreen> {
  late Future<List<Map<String, dynamic>>> _contactDataFuture;
  bool _isDeleting = false;
  bool _isAdding = false;

  // Mapping for contact types (used in the dropdown)
  final Map<int, String> _contactTypeLabels = {
    1: 'Telefonnummer Privat',
    2: 'Mobilnummer Privat',
    3: 'Fax Privat',
    4: 'E-Mail Privat',
    5: 'Telefonnummer Geschäftlich',
    6: 'Mobilnummer Geschäftlich',
    7: 'Fax Geschäftlich',
    8: 'E-Mail Geschäftlich',
  };

  int?
      _selectedKontaktTyp; // To store the selected contact type from the dropdown
  final TextEditingController _kontaktController =
      TextEditingController(); // Controller for the contact string

  // Regex for email validation
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  // Basic regex for phone numbers (allows digits, spaces, hyphens, plus sign, parentheses)
  final RegExp _phoneFaxMobileRegex = RegExp(r'^[0-9\s\-\+\(\)]+$');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // --- Data Loading and Refresh ---
  void _loadInitialData() {
    setState(() {
      _contactDataFuture =
          Future.value([]); // Clear current data to show spinner
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _contactDataFuture =
          apiService.fetchKontakte(widget.personId).then((data) {
        LoggerService.logInfo('Contact data structure: $data');
        return data;
      });
      LoggerService.logInfo(
        'ContactDataScreen: Initiating contact data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      _contactDataFuture = Future.value([]); // Provide an empty list on error
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
              style: UIConstants.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIConstants.dialogContentStyle,
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
              padding: UIConstants.dialogPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: UIConstants.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Abbrechen',
                            style: UIConstants.dialogButtonStyle.copyWith(
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
                      style: UIConstants.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Löschen',
                            style: UIConstants.dialogButtonStyle.copyWith(
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

    // FIX: Add mounted check before using context after await
    if (!mounted) return;

    if (confirmDelete == null || !confirmDelete) {
      LoggerService.logInfo('Contact deletion cancelled by user.');
      // If deletion is cancelled, ensure _isDeleting is reset if it was set beforehand.
      if (mounted) {
        // Already checked above, but good to be explicit if this block is executed after an async call
        setState(() {
          _isDeleting = false;
        });
      }
      return;
    }

    setState(() {
      _isDeleting =
          true; // Show loading indicator (e.g., disable delete buttons)
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.deleteKontakt(
        widget.personId, // personId
        kontaktId, // kontaktId
        kontaktTyp, // kontaktTyp
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontakt erfolgreich gelöscht.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
          _loadInitialData(); // Refresh the list after successful deletion
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Löschen des Kontakts.'),
              duration: UIConstants.snackBarDuration,
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
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false; // Hide loading indicator
        });
      }
    }
  }

  // --- Add Contact Logic ---
  Future<void> _onAddContact() async {
    final String kontaktValue = _kontaktController.text.trim();

    if (_selectedKontaktTyp == null || kontaktValue.isEmpty) {
      if (mounted) {
        // FIX: Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte Kontakttyp und Kontaktwert eingeben.'),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
      return;
    }

    // Input Validation based on KontaktTyp
    String? validationErrorMessage;
    if (_selectedKontaktTyp == 4 || _selectedKontaktTyp == 8) {
      // E-Mail Privat or E-Mail Geschäftlich
      if (!_emailRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
      }
    } else if ([1, 2, 3, 5, 6, 7].contains(_selectedKontaktTyp)) {
      // Phone, Mobile, Fax types
      if (!_phoneFaxMobileRegex.hasMatch(kontaktValue)) {
        validationErrorMessage =
            'Bitte geben Sie eine gültige Telefon-/Faxnummer ein (nur Ziffern, +, -, (, ) erlaubt).';
      }
    }

    if (validationErrorMessage != null) {
      if (mounted) {
        // FIX: Add mounted check
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationErrorMessage),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
      return;
    }

    setState(() {
      _isAdding = true; // Set loading state for add operation
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.addKontakt(
        widget.personId, // personId
        _selectedKontaktTyp!, // kontaktTyp
        kontaktValue, // kontakt
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontakt erfolgreich hinzugefügt.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
          _kontaktController.clear(); // Clear text field
          _selectedKontaktTyp = null; // Reset dropdown
          _loadInitialData(); // Refresh the list after successful addition
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Hinzufügen des Kontakts.'),
              duration: UIConstants.snackBarDuration,
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
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false; // Reset loading state
        });
        Navigator.of(context).pop(); // Close the add contact dialog
      }
    }
  }

  // --- Display Add Contact Form ---
  void _showAddContactForm() {
    _selectedKontaktTyp = null; // Reset selected type
    _kontaktController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid conflicts
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              'Neuen Kontakt hinzufügen',
              style: UIConstants.dialogTitleStyle,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<int>(
                  decoration: UIConstants.formInputDecoration.copyWith(
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
                      // setState for dialog's own state
                      _selectedKontaktTyp = newValue;
                    });
                  },
                ),
                const SizedBox(height: UIConstants.spacingM),
                TextFormField(
                  controller: _kontaktController,
                  decoration: UIConstants.formInputDecoration.copyWith(
                    labelText: 'Kontakt',
                    hintText: 'z.B. email@beispiel.de oder 0123 456789',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  keyboardType: TextInputType
                      .text, // Set based on type, can be dynamic later
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
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Distribute space between buttons
                children: [
                  Expanded(
                    // "Abbrechen" button takes available space
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.cancelButtonBackground,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            color: UIConstants.closeIcon,
                          ),
                          SizedBox(width: UIConstants.spacingS),
                          Text(
                            'Abbrechen',
                            style:
                                TextStyle(color: UIConstants.cancelButtonText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: UIConstants.spacingM,
                  ), // Space between buttons
                  Expanded(
                    // "Hinzufügen" button takes available space
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _onAddContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.acceptButtonBackground,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: _isAdding
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.circularProgressIndicator,
                              ),
                              strokeWidth: 2,
                            )
                          : Row(
                              // <-- Row for icon and text
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: UIConstants.checkIcon,
                                  size: UIConstants.bodyFontSize + 4.0,
                                ),
                                // OK icon
                                const SizedBox(
                                  width: UIConstants.spacingS,
                                ),
                                Text(
                                  'Hinzufügen',
                                  style: UIConstants.dialogButtonStyle.copyWith(
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
    _kontaktController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Kontaktdaten',
          style: UIConstants.appBarTitleStyle,
        ),
        actions: [
          const Padding(
            padding: UIConstants.appBarRightPadding,
            child: ConnectivityIcon(),
          ),
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
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
              child: Text(
                'Fehler beim Laden der Kontaktdaten: ${snapshot.error}',
                style: UIConstants.errorStyle,
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<Map<String, dynamic>> categorizedContactData =
                snapshot.data!;

            final bool hasContacts = categorizedContactData.any(
              (group) => (group['contacts'] as List?)?.isNotEmpty ?? false,
            );

            if (!hasContacts) {
              return const Center(child: Text('Keine Kontaktdaten verfügbar.'));
            }

            return Padding(
              padding: const EdgeInsets.all(UIConstants.spacingM),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: UIConstants.startCrossAlignment,
                  children: [
                    // Display categorized contacts
                    for (var category in categorizedContactData)
                      if ((category['contacts'] as List?)?.isNotEmpty ?? false)
                        _buildContactGroup(
                          category['category']?.toString() ?? 'Unbekannt',
                          (category['contacts'] as List?)
                                  ?.cast<Map<String, dynamic>>() ??
                              [],
                        ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('Keine Kontaktdaten verfügbar.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactForm,
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.add,
          color: UIConstants.addIcon,
          size: UIConstants.bodyFontSize + 4.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper method to build a contact group (e.g., "Privat")
  Widget _buildContactGroup(
    String categoryTitle,
    List<Map<String, dynamic>> contacts,
  ) {
    return Column(
      crossAxisAlignment: UIConstants.startCrossAlignment,
      children: [
        _buildSectionTitle(categoryTitle, color: UIConstants.defaultAppColor),
        for (var contact in contacts)
          if (contact['type'] != null && contact['value'] != null)
            _buildReadOnlyTextField(
              label: contact['type'].toString(),
              value: contact['value'].toString(),
              kontaktId: contact['kontaktId'] as int? ?? 0,
              rawKontaktTyp: contact['rawKontaktTyp'] as int? ?? 0,
              onDelete: _onDeleteContact,
              isDeleting: _isDeleting,
            ),
        const SizedBox(height: UIConstants.spacingM),
      ],
    );
  }

  // A dedicated helper for read-only text fields with a delete icon
  Widget _buildReadOnlyTextField({
    required String label,
    required String value,
    required int kontaktId,
    required int rawKontaktTyp,
    required Function(int kontaktId, int kontaktTyp, String value, String label)
        onDelete,
    required bool isDeleting,
  }) {
    final displayValue = value.isNotEmpty ? value : '-';
    final displayLabel = label.isNotEmpty ? label : 'Unbekannt';

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingM / 2),
      child: TextFormField(
        initialValue: displayValue,
        readOnly: true,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: UIConstants.bodyFontSize,
        ),
        decoration: UIConstants.formInputDecoration.copyWith(
          labelText: displayLabel,
          //labelStyle: UIConstants.formLabelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: isDeleting ? null : displayLabel,
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

  // --- Helper method for section titles (kept as before) ---
  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
      child: Text(
        title,
        style: UIConstants.titleStyle.copyWith(
          color: color,
        ),
      ),
    );
  }
}
