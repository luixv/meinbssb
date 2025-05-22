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

  late Future<List<dynamic>> _contactDataFuture;

  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false; // Track loading state for the submit button.
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    // Assign the user data.
    _userData = widget.userData['data'] ?? {};
    _loadInitialData();
  }

  void _loadInitialData() {
    // Populate the text fields with the user's data.  Use _userData
    _privatTelefonController.text = _userData['TELEFONNUMMER_PRIVAT'] ?? '';
    _privatMobilnummerController.text = _userData['MOBILNUMMER_PRIVAT'] ?? '';
    _privatEmailController.text = _userData['EMAIL_PRIVAT'] ?? '';
    _privatFaxController.text = _userData['FAX_PRIVAT'] ?? '';

    _geschaeftlichTelefonController.text =
        _userData['TELEFONNUMMER_GESCHAEFTLICH'] ?? '';
    _geschaeftlichMobilnummerController.text =
        _userData['MOBILNUMMER_GESCHAEFTLICH'] ?? '';
    _geschaeftlichEmailController.text = _userData['EMAIL_GESCHAEFTLICH'] ?? '';
    _geschaeftlichFaxController.text = _userData['FAX_GESCHAEFTLICH'] ?? '';

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      _contactDataFuture = apiService.fetchKontakte(
        widget.personId,
      );

      print(_contactDataFuture);
    } catch (e) {
      LoggerService.logError('Error loading data: $e');
      _contactDataFuture = Future.value([]);
    }

    LoggerService.logInfo('ContactDataScreen initialized');
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from StammdatenScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        const bool success = true;

        if (success) {
          LoggerService.logInfo('Stammdaten updated successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stammdaten erfolgreich aktualisiert.'),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
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
    // Dispose controllers
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
          'Kontaktdaten', // Schützenausweis Kontaktdaten
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
      body: Padding(
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
                ), // Changed color
                _buildTextField(
                  label: 'Telefonnummer',
                  controller: _privatTelefonController,
                  validator: (value) {
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Mobilnummer',
                  controller: _privatMobilnummerController,
                  validator: (value) {
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'E-Mail',
                  controller: _privatEmailController,
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
                  validator: (value) {
                    return null;
                  },
                ),
                _buildSectionTitle(
                  'Geschäftlich',
                  color: UIConstants.defaultAppColor,
                ), // Changed color
                _buildTextField(
                  label: 'Telefonnummer',
                  controller: _geschaeftlichTelefonController,
                  validator: (value) {
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Mobilnummer',
                  controller: _geschaeftlichMobilnummerController,
                  validator: (value) {
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'E-Mail',
                  controller: _geschaeftlichEmailController,
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
                  validator: (value) {
                    return null;
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
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    // Added color parameter
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
      ),
    );
  }
}
