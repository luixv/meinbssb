// In lib/screens/contact_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/api_service.dart';
import '/services/logger_service.dart';

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
  bool _isAdding = false; // New: State variable for add contact loading

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
      _contactDataFuture = apiService.fetchKontakte(widget.personId);
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
    String contactValue, // Added to display in dialog
    String contactLabel, // Added to display in dialog
  ) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundGreen,
          title: const Center(
            child: Text(
              'Kontakt löschen',
              style: TextStyle(
                color: UIConstants.defaultAppColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: RichText(
            // Use RichText for mixed styles
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
                color: UIConstants.black,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Sind Sie sicher, dass Sie den Kontakt '),
                TextSpan(
                  text: '$contactLabel: $contactValue', // No quotes here
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // Bold the contact info
                ),
                const TextSpan(text: ' löschen möchten?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.defaultPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Do not delete
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.cancelButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: Text(
                        'Abbrechen',
                        style: UIConstants.bodyStyle.copyWith(
                          color: UIConstants.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: UIConstants.defaultSpacing,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true); // Confirm delete
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.acceptButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: Text(
                        'Löschen',
                        style: UIConstants.bodyStyle.copyWith(
                          color: UIConstants.white,
                        ),
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
          // Navigator.of(context).pop(); // FIX: This pop might be too soon, ensure it's safe.
          // For now, it's safer to pop after the data reloads if it's meant to close the dialog.
          // If the dialog is still open, the mounted check will apply to the ScaffoldMessenger.
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
        // If the dialog should close automatically on success, ensure it's done here.
        // This 'pop' needs to be in the 'if (mounted)' block as well.
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
          backgroundColor: UIConstants.backgroundGreen,
          title: const Center(
            // Center the title
            child: Text(
              'Neuen Kontakt hinzufügen',
              style: TextStyle(
                color: UIConstants.defaultAppColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                DropdownButtonFormField<int>(
                  decoration: UIConstants.defaultInputDecoration.copyWith(
                    labelText: 'Kontakttyp',
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Apply auto behavior
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
                const SizedBox(height: UIConstants.defaultSpacing),
                TextFormField(
                  controller: _kontaktController,
                  decoration: UIConstants.defaultInputDecoration.copyWith(
                    labelText: 'Kontakt',
                    hintText: 'z.B. email@beispiel.de oder 0123 456789',
                    floatingLabelBehavior:
                        FloatingLabelBehavior.auto, // Apply auto behavior
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
                horizontal: UIConstants.defaultPadding,
              ), // Add horizontal padding to the row
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
                        backgroundColor: UIConstants.cancelButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: Text(
                        'Abbrechen',
                        style: UIConstants.bodyStyle.copyWith(
                          fontSize: UIConstants
                              .bodyFontSize, // Ensure font size consistency
                          color: UIConstants.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: UIConstants.defaultSpacing,
                  ), // Space between buttons
                  Expanded(
                    // "Hinzufügen" button takes available space
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _onAddContact,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.acceptButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: _isAdding
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.white,
                              ),
                              strokeWidth: 2,
                            )
                          : Text(
                              'Hinzufügen',
                              style: UIConstants.bodyStyle.copyWith(
                                fontSize: UIConstants
                                    .bodyFontSize, // Ensure font size consistency
                                color: UIConstants.white,
                              ),
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
    widget.onLogout(); // Call the logout function provided by the parent.
    if (mounted) {
      // FIX: Add mounted check
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
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Kontaktdaten',
          style: UIConstants.titleStyle,
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
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
              child:
                  Text('Fehler beim Laden der Kontaktdaten: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<Map<String, dynamic>> categorizedContactData =
                snapshot.data!;

            final bool hasContacts = categorizedContactData
                .any((group) => (group['contacts'] as List).isNotEmpty);

            if (!hasContacts) {
              return const Center(child: Text('Keine Kontaktdaten verfügbar.'));
            }

            return Padding(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var categoryGroup in categorizedContactData)
                      if ((categoryGroup['contacts'] as List).isNotEmpty)
                        _buildContactGroup(
                          categoryGroup['category'] as String,
                          categoryGroup['contacts']
                              as List<Map<String, dynamic>>,
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
      // --- Floating Action Button (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactForm,
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.add, color: UIConstants.white),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(categoryTitle, color: UIConstants.defaultAppColor),
        for (var contact in contacts)
          _buildReadOnlyTextField(
            label: contact['type'] as String,
            value: contact['value'] as String,
            kontaktId: contact['kontaktId'] as int, // Pass kontaktId
            rawKontaktTyp:
                contact['rawKontaktTyp'] as int, // Pass rawKontaktTyp
            onDelete: _onDeleteContact, // Pass the delete callback
            isDeleting: _isDeleting, // Pass the global deleting state
          ),
        const SizedBox(height: UIConstants.defaultSpacing),
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
        onDelete, // Updated signature
    required bool isDeleting,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        initialValue: value.isNotEmpty ? value : '-',
        readOnly: true,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: UIConstants.bodyFontSize,
        ),
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          // For read-only fields, 'always' might still be preferred for clarity,
          // but if you want 'auto' behavior here too, you can change it.
          // For now, keeping as 'always' for consistency with how read-only data is often displayed.
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: UIConstants.deleteIcon, // Example color
            onPressed: isDeleting
                ? null // Disable button while deleting
                : () => onDelete(
                      kontaktId,
                      rawKontaktTyp,
                      value, // Pass contact value
                      label, // Pass contact label
                    ), // Call delete handler
          ),
        ),
      ),
    );
  }

  // --- Helper method for section titles (kept as before) ---
  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing / 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: UIConstants.titleFontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
