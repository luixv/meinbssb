import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/logger_service.dart';
import 'package:intl/intl.dart';

class PersonDataScreen extends StatefulWidget {
  const PersonDataScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  PersonDataScreenState createState() => PersonDataScreenState();
}

class PersonDataScreenState extends State<PersonDataScreen> {
  // Form Controllers
  final TextEditingController _passnummerController = TextEditingController();
  final TextEditingController _geburtsdatumController = TextEditingController();
  final TextEditingController _titelController = TextEditingController();
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _strasseHausnummerController =
      TextEditingController();
  final TextEditingController _postleitzahlController = TextEditingController();
  final TextEditingController _ortController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false; // Loading state for the submit button
  // Initial Data Loading (Populate fields)
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Populate the text fields with the user's data.
    _passnummerController.text =
        widget.userData['PASSNUMMER']?.toString() ?? ''; //ADDED ?.toString()
    // Format the date if it's not null
    if (widget.userData['GEBURTSDATUM'] != null) {
      try {
        final parsedDate = DateTime.parse(widget.userData['GEBURTSDATUM']);
        _geburtsdatumController.text =
            DateFormat('dd.MM.yyyy').format(parsedDate);
      } catch (e) {
        LoggerService.logError(
          'Error parsing date: ${widget.userData['GEBURTSDATUM']}',
        );
        _geburtsdatumController.text =
            'Invalid Date'; // Or some default error message
      }
    } else {
      _geburtsdatumController.text = '';
    }

    _titelController.text = widget.userData['TITEL']?.toString() ?? '';
    _vornameController.text = widget.userData['VORNAME']?.toString() ?? '';
    _nachnameController.text = widget.userData['NAMEN']?.toString() ?? '';
    _strasseHausnummerController.text =
        widget.userData['STRASSE']?.toString() ?? '';
    _postleitzahlController.text = widget.userData['PLZ']?.toString() ?? '';
    _ortController.text = widget.userData['ORT']?.toString() ?? '';

    LoggerService.logInfo('KontaktdatenScreen initialized');
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from KontaktdatenScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed(
      '/login',
    ); // Navigate to the login screen.  Use pushReplacementNamed
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Simulate an API call (this will be replaced with the actual API call)
      try {
        // In a real app, you'd call your ApiService here to update the data.
        // Example:
        // final apiService = Provider.of<ApiService>(context, listen: false);
        // final success = await apiService.updateKontaktdaten({
        //   'PASSNUMMER': _passnummerController.text,
        //   'GEBURTSDATUM': _geburtsdatumController.text, // Consider re-parsing if needed
        //   'TITEL': _titelController.text,
        //   'VORNAME': _vornameController.text,
        //   'NAMEN': _nachnameController.text,
        //   'STRASSE_HAUSNUMMER': _strasseHausnummerController.text,
        //   'PLZ': _postleitzahlController.text,
        //   'ORT': _ortController.text,
        //   //  'PERSONID' : widget.userData['PERSONID'], //DO NOT SEND PERSONID.
        // });

        // Simulate a successful response (replace with actual response handling)
        await Future.delayed(
          const Duration(seconds: 2),
        ); // Simulate network delay

        // Simulate different responses for testing
        const bool success = true; // Or false, to test error handling.

        if (success) {
          LoggerService.logInfo('Kontaktdaten updated successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kontaktdaten erfolgreich aktualisiert.'),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
          // You might want to navigate to another screen or update the UI here.
        }
      } catch (error) {
        LoggerService.logError('Error updating Kontaktdaten: $error');
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
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed.
    _passnummerController.dispose();
    _geburtsdatumController.dispose();
    _titelController.dispose();
    _vornameController.dispose();
    _nachnameController.dispose();
    _strasseHausnummerController.dispose();
    _postleitzahlController.dispose();
    _ortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI for the Kontaktdaten screen.
    return Scaffold(
      backgroundColor:
          UIConstants.backgroundGreen, // Consistent background color
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the default back button
        title: const Text(
          'Persönliche Daten', // Set the title of the AppBar
          style: UIConstants.titleStyle, // Use the title style from UIConstants
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child:
                ConnectivityIcon(), // Add the ConnectivityIcon here, as in StartScreen
          ),
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout:
                _handleLogout, // Use the logout handler defined in this class
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          UIConstants.defaultPadding,
        ), // Use default padding
        child: Form(
          //Wrap with a form
          key: _formKey,
          child: SingleChildScrollView(
            // Make the content scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Left-align labels.  This is mostly handled by the _buildTextField now.
              children: <Widget>[
                //const LogoWidget(), //  NO LOGO HERE
                const SizedBox(height: UIConstants.defaultSpacing),
                _buildTextField(
                  // Use the helper method for consistent text fields
                  label: 'Passnummer',
                  controller: _passnummerController,
                  isReadOnly: true,
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  inputTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // Make Value Bold
                ),
                _buildTextField(
                  label: 'Geburtsdatum',
                  controller: _geburtsdatumController,
                  isReadOnly: true,
                  floatingLabelBehavior:
                      FloatingLabelBehavior.always, // Always show label on top
                  inputTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ), // Make Value Bold
                ),
                _buildTextField(
                  label: 'Titel',
                  controller: _titelController,
                  floatingLabelBehavior: FloatingLabelBehavior
                      .auto, // Use the auto behavior, like the login screen
                  validator: (value) {
                    return null; // It can be empty
                  },
                ),
                _buildTextField(
                  label: 'Vorname',
                  controller: _vornameController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vorname ist erforderlich';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Nachname',
                  controller: _nachnameController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nachname ist erforderlich';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Straße + Hausnummer',
                  controller: _strasseHausnummerController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Straße und Hausnummer sind erforderlich';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Postleitzahl',
                  controller: _postleitzahlController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Postleitzahl ist erforderlich';
                    }
                    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                      return 'Ungültige Postleitzahl';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Ort',
                  controller: _ortController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ort ist erforderlich';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: UIConstants.defaultSpacing),
                SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : _submitForm, // Disable when loading
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
      ),
    );
  }

  // Helper method to create a text field with label
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    FloatingLabelBehavior floatingLabelBehavior =
        FloatingLabelBehavior.auto, // Added this parameter
    TextStyle? labelStyle,
    TextStyle? inputTextStyle,
    Color? backgroundColor, // Added background color parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        controller: controller,
        style: inputTextStyle ??
            const TextStyle(
              fontSize: UIConstants.bodyFontSize,
            ), // Input text style.  Important
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label, // Now set here
          labelStyle: labelStyle ??
              const TextStyle(
                fontSize: UIConstants.subtitleFontSize,
              ), // Ensure label style is set.
          floatingLabelBehavior:
              floatingLabelBehavior, // Use the parameter here
          hintText:
              isReadOnly ? null : label, // Only show hint for editable fields
          fillColor: backgroundColor, // Use the provided background color
          filled: backgroundColor !=
              null, // Only fill if a color is provided.  Important.
        ),
        validator: validator,
        readOnly: isReadOnly,
      ),
    );
  }
}
