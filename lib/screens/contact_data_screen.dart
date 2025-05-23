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
  // Form Controllers for Privat
  final TextEditingController _privatTelefonController =
      TextEditingController();
  final TextEditingController _privatMobilnummerController =
      TextEditingController();
  final TextEditingController _privatEmailController = TextEditingController();
  final TextEditingController _privatFaxController = TextEditingController();

  // Form Controllers for Geschäftlich
  final TextEditingController _geschaeftlichTelefonController =
      TextEditingController();
  final TextEditingController _geschaeftlichMobilnummerController =
      TextEditingController();
  final TextEditingController _geschaeftlichEmailController =
      TextEditingController();
  final TextEditingController _geschaeftlichFaxController =
      TextEditingController();

  // This Future will now hold a single Map<String, dynamic> for contact data
  late Future<Map<String, dynamic>> _contactDataFuture;

  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadInitialData(); // Start fetching the contact-specific data
  }

  void _loadInitialData() {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      // Assign the Future returned by fetchKontakte.
      // It now directly returns a Map<String, dynamic>
      _contactDataFuture = apiService.fetchKontakte(
        widget.personId,
      );
      LoggerService.logInfo(
        'ContactDataScreen: Initiating contact data fetch.',
      );
    } catch (e) {
      LoggerService.logError('Error setting up contact data fetch: $e');
      // If there's an immediate error before the Future even starts,
      // provide a resolved Future with an empty map to prevent FutureBuilder errors.
      _contactDataFuture = Future.value({});
    }
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from ContactdataScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Collect current data from controllers
        Map<String, dynamic> currentContactData = {
          'TELEFONNUMMER_PRIVAT': _privatTelefonController.text,
          'MOBILNUMMER_PRIVAT': _privatMobilnummerController.text,
          'EMAIL_PRIVAT': _privatEmailController.text,
          'FAX_PRIVAT': _privatFaxController.text,
          'TELEFONNUMMER_GESCHAEFTLICH': _geschaeftlichTelefonController.text,
          'MOBILNUMMER_GESCHAEFTLICH': _geschaeftlichMobilnummerController.text,
          'EMAIL_GESCHAEFTLICH': _geschaeftlichEmailController.text,
          'FAX_GESCHAEFTLICH': _geschaeftlichFaxController.text,
        };
        LoggerService.logInfo('Submitting form data: $currentContactData');

        // Here you would call an API service method to update the contact data
        // For example: await apiService.updateKontakte(widget.personId, currentContactData);
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call

        LoggerService.logInfo('Stammdaten updated successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stammdaten erfolgreich aktualisiert.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      } catch (error) {
        LoggerService.logError('Error updating Stammdaten: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ein Fehler ist aufgetreten: $error'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _privatTelefonController.dispose();
    _privatMobilnummerController.dispose();
    _privatEmailController.dispose();
    _privatFaxController.dispose();
    _geschaeftlichTelefonController.dispose();
    _geschaeftlichMobilnummerController.dispose();
    _geschaeftlichEmailController.dispose();
    _geschaeftlichFaxController.dispose();
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
            userData: widget.userData, // Pass the initial user data to the menu
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      // ---
      /// Use a FutureBuilder to display content based on the Future's state
      body: FutureBuilder<Map<String, dynamic>>(
        // <--- **IMPORTANT CHANGE HERE:** Expecting Map<String, dynamic>
        future: _contactDataFuture, // The Future to wait for
        builder: (context, snapshot) {
          // Check the state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If data is still loading, show a loading indicator
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If the Future completed with an error
            LoggerService.logError(
              'Error loading contact data in FutureBuilder: ${snapshot.error}',
            );
            return Center(
              child:
                  Text('Fehler beim Laden der Kontaktdaten: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // If data has been successfully fetched and is not null
            // snapshot.data is now directly the Map<String, dynamic>
            final Map<String, dynamic> fetchedContactData = snapshot.data!;

            // Populate the text controllers with the fetched data
            // This ensures your form fields display the values from the API response
            _privatTelefonController.text =
                fetchedContactData['TELEFONNUMMER_PRIVAT'] ?? '';
            _privatMobilnummerController.text =
                fetchedContactData['MOBILNUMMER_PRIVAT'] ?? '';
            _privatEmailController.text =
                fetchedContactData['EMAIL_PRIVAT'] ?? '';
            _privatFaxController.text = fetchedContactData['FAX_PRIVAT'] ?? '';

            _geschaeftlichTelefonController.text =
                fetchedContactData['TELEFONNUMMER_GESCHAEFTLICH'] ?? '';
            _geschaeftlichMobilnummerController.text =
                fetchedContactData['MOBILNUMMER_GESCHAEFTLICH'] ?? '';
            _geschaeftlichEmailController.text =
                fetchedContactData['EMAIL_GESCHAEFTLICH'] ?? '';
            _geschaeftlichFaxController.text =
                fetchedContactData['FAX_GESCHAEFTLICH'] ?? '';

            // Return the actual form content, now that controllers are populated
            return Padding(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildSectionTitle(
                        'Privat',
                        color: UIConstants.defaultAppColor,
                      ),
                      _buildTextField(
                        label: 'Telefonnummer',
                        controller: _privatTelefonController,
                        keyboardType: TextInputType
                            .phone, // Suggest appropriate keyboard type
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Mobilnummer',
                        controller: _privatMobilnummerController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      _buildTextField(
                        label: 'E-Mail',
                        controller: _privatEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value)) {
                              return 'Ungültige E-Mail-Adresse';
                            }
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Fax',
                        controller: _privatFaxController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      _buildSectionTitle(
                        'Geschäftlich',
                        color: UIConstants.defaultAppColor,
                      ),
                      _buildTextField(
                        label: 'Telefonnummer',
                        controller: _geschaeftlichTelefonController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Mobilnummer',
                        controller: _geschaeftlichMobilnummerController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      _buildTextField(
                        label: 'E-Mail',
                        controller: _geschaeftlichEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value)) {
                              return 'Ungültige E-Mail-Adresse';
                            }
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Fax',
                        controller: _geschaeftlichFaxController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          /* Add validation */ return null;
                        },
                      ),
                      const SizedBox(height: UIConstants.defaultSpacing),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: UIConstants.buttonPadding,
                            backgroundColor: UIConstants.lightGreen,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    UIConstants.white,
                                  ),
                                )
                              : const Text(
                                  'Absenden',
                                  style: TextStyle(
                                    fontSize: UIConstants.bodyFontSize,
                                    color: UIConstants.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // If data is null or the map is empty (e.g., no contacts found or no valid types)
            return const Center(child: Text('Keine Kontaktdaten verfügbar.'));
          }
        },
      ),
    );
  }

  // --- Helper methods (keeping your original implementations) ---
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
    TextInputType keyboardType = TextInputType.text, // Added keyboardType
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: UIConstants.bodyFontSize),
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          labelStyle: const TextStyle(fontSize: UIConstants.subtitleFontSize),
          floatingLabelBehavior: floatingLabelBehavior,
          hintText: isReadOnly ? null : label,
        ),
        validator: validator,
        readOnly: isReadOnly,
        keyboardType: keyboardType, // Apply keyboardType
      ),
    );
  }
}
