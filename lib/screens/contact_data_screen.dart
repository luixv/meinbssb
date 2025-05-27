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

  // Added a state variable to manage loading for delete operations
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Start fetching the contact-specific data
  }

  // --- Data Loading and Refresh ---
  void _loadInitialData() {
    setState(() {
      // Set future to null to indicate loading state if you want to show a fresh spinner
      // or just re-assign the future to trigger FutureBuilder rebuild.
      _contactDataFuture = Future.value([]); // Clear current data
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _contactDataFuture = apiService.fetchKontakte(widget.personId);
      LoggerService.logInfo(
          'ContactDataScreen: Initiating contact data fetch.',);
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      _contactDataFuture = Future.value([]); // Provide an empty list on error
    }
  }

  // --- Contact Deletion Logic ---
  Future<void> _onDeleteContact(int kontaktId, int kontaktTyp) async {
    setState(() {
      _isDeleting =
          true; // Show loading indicator (e.g., disable delete buttons)
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final bool success = await apiService.deleteKontakt(
        widget.personId,
        kontaktId,
        kontaktTyp,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kontakt erfolgreich gelöscht.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
          // Refresh the list after successful deletion
          _loadInitialData();
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

  // --- Logout Handler ---
  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactdataScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
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
    );
  }

  // Helper method to build a contact group (e.g., "Privat")
  Widget _buildContactGroup(
      String categoryTitle, List<Map<String, dynamic>> contacts,) {
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
    required int kontaktId, // New: Required kontaktId
    required int rawKontaktTyp, // New: Required rawKontaktTyp
    required Function(int kontaktId, int kontaktTyp)
        onDelete, // New: Callback for delete
    required bool isDeleting, // New: To disable delete button during operation
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        initialValue: value.isNotEmpty ? value : '-',
        readOnly: true,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: UIConstants.bodyFontSize,),
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: UIConstants.defaultAppColor, // Example color
            onPressed: isDeleting
                ? null // Disable button while deleting
                : () =>
                    onDelete(kontaktId, rawKontaktTyp), // Call delete handler
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
