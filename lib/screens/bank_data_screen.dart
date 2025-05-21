import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/logger_service.dart';

class BankDataScreen extends StatefulWidget {
  const BankDataScreen(
    this.userData, {
    required this.webloginId,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final Map<String, dynamic> userData;
  final int webloginId;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  BankDataScreenState createState() => BankDataScreenState();
}

class BankDataScreenState extends State<BankDataScreen> {
  // Form Controllers
  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false; // Loading state for the submit button
  Map<String, dynamic> _userData = {}; // To hold simplified user data

  @override
  void initState() {
    super.initState();
    _userData = widget.userData['data'] ?? {}; // Assign nested data
    _loadInitialData();
  }

  void _loadInitialData() {
    // Populate the text fields with the user's data (if available)
    // For this example, we assume these fields might be part of userData
    // If not, they will remain empty as per ?? ''
    _kontoinhaberController.text = _userData['KONTOINHABER']?.toString() ?? '';
    _ibanController.text = _userData['IBAN']?.toString() ?? '';
    _bicController.text = _userData['BIC']?.toString() ?? '';

    LoggerService.logInfo('BankDataScreen initialized');
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from BankDataScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Navigate to the login screen
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Simulate an API call to save bank data
        // In a real app, you'd call your ApiService here to update the data.
        // Example:
        // final apiService = Provider.of<ApiService>(context, listen: false);
        // final success = await apiService.updateBankData({
        //   'KONTOINHABER': _kontoinhaberController.text,
        //   'IBAN': _ibanController.text,
        //   'BIC': _bicController.text,
        // });

        await Future.delayed(
            const Duration(seconds: 2),); // Simulate network delay

        const bool success = true; // Simulate a successful response

        if (success) {
          LoggerService.logInfo('Bank data updated successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bankdaten erfolgreich aktualisiert.'),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
        }
      } catch (error) {
        LoggerService.logError('Error updating bank data: $error');
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

  // IBAN Validator functions (copied from your provided iban_checker.dart)
  bool validateIBAN(String iban) {
    iban =
        iban.toUpperCase().replaceAll(' ', ''); // Remove spaces and uppercase

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(iban)) {
      return false; // Invalid characters
    }

    if (iban.length < 5) {
      return false; // Too short to be a valid IBAN
    }

    String countryCode = iban.substring(0, 2);
    String checkDigits = iban.substring(2, 4);
    String bban = iban.substring(4);

    String movedIban = bban + countryCode + checkDigits;

    String numericIban = '';
    for (int i = 0; i < movedIban.length; i++) {
      String char = movedIban[i];
      if (RegExp(r'^[0-9]$').hasMatch(char)) {
        numericIban += char;
      } else {
        numericIban += (char.codeUnitAt(0) - 55).toString(); // A=10, B=11, ...
      }
    }

    int remainder = _mod97(numericIban);

    return remainder == 1;
  }

  int _mod97(String numericIban) {
    int remainder = 0;
    for (int i = 0; i < numericIban.length; i++) {
      remainder = (remainder * 10 + int.parse(numericIban[i])) % 97;
    }
    return remainder;
  }

  // BIC Validator
  String? validateBIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'BIC ist erforderlich';
    }
    // BIC (SWIFT code) is 8 or 11 alphanumeric characters.
    // Format: AAAA BB CC DDD (AAAA: bank code, BB: country code, CC: location code, DDD: optional branch code)
    // Only A-Z and 0-9 are allowed.
    final bicRegex = RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$');
    if (!bicRegex.hasMatch(value.toUpperCase())) {
      return 'Ungültiger BIC (Beispiel: DEUTDEFFXXX)';
    }
    return null;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed.
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Bankdaten',
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
                const SizedBox(height: UIConstants.defaultSpacing),
                _buildTextField(
                  label: 'Kontoinhaber',
                  controller: _kontoinhaberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kontoinhaber ist erforderlich';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'IBAN',
                  controller: _ibanController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'IBAN ist erforderlich';
                    }
                    if (!validateIBAN(value)) {
                      return 'Ungültige IBAN';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'BIC',
                  controller: _bicController,
                  validator: validateBIC, // Use the dedicated BIC validator
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
                                UIConstants.white,),
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
    // Removed floatingLabelBehavior parameter from here, as it's now fixed to auto
    TextStyle? inputTextStyle,
    Color? backgroundColor,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        controller: controller,
        style: inputTextStyle ??
            const TextStyle(
              fontSize: UIConstants.bodyFontSize,
            ),
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: UIConstants.subtitleFontSize,), // Fixed label style
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Set to auto for desired behavior
          hintText: isReadOnly ? null : label,
          fillColor: backgroundColor,
          filled: backgroundColor != null,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        readOnly: isReadOnly,
      ),
    );
  }
}
