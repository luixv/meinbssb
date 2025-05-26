import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/logger_service.dart';
import '/services/api/bank_service.dart';
import '/services/api_service.dart'; // Import ApiService
import 'package:provider/provider.dart'; // Import Provider

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
// To hold simplified user data

  @override
  void initState() {
    super.initState();
// Assign nested data
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final apiService = Provider.of<ApiService>(
      context,
      listen: false,
    ); // Get ApiService instance

    try {
      final bankData = await apiService.fetchBankdaten(widget.webloginId);
      if (bankData.isNotEmpty) {
        _kontoinhaberController.text =
            bankData['KONTOINHABER']?.toString() ?? '';
        _ibanController.text = bankData['IBAN']?.toString() ?? '';
        _bicController.text = bankData['BIC']?.toString() ?? '';
      } else {
        LoggerService.logWarning(
          'No bank data found for webloginId: ${widget.webloginId}',
        );
      }
    } catch (error) {
      LoggerService.logError('Error fetching bank data: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Bankdaten: $error'),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
    }

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
        final apiService = Provider.of<ApiService>(context, listen: false);
        final response = await apiService.registerBankdaten(
          widget.webloginId,
          _kontoinhaberController.text,
          _ibanController.text,
          _bicController.text,
        );

        if (response.isNotEmpty && response.containsKey('BankdatenWebID')) {
          final int bankdatenWebId = response['BankdatenWebID'];
          LoggerService.logInfo(
            'Bank data updated successfully, ID: $bankdatenWebId',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bankdaten erfolgreich aktualisiert.'),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
        } else {
          LoggerService.logError(
            'Failed to update bank data: Unexpected API response',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.',
                ),
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
          'Zahlungsart',
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
                    if (!BankService.validateIBAN(value)) {
                      return 'Ungültige IBAN';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'BIC',
                  controller: _bicController,
                  validator: BankService
                      .validateBIC, // Use the dedicated BIC validator
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

  // Helper method to create a text field with label
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
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
            fontSize: UIConstants.subtitleFontSize,
          ), // Fixed label style
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
