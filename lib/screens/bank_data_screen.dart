// In lib/screens/bank_data_screen.dart

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '../services/core/logger_service.dart';
import '/services/api/bank_service.dart';
import '/services/api_service.dart';
import 'package:provider/provider.dart';
import '/screens/bank_data_result_screen.dart';

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
  final TextEditingController _kontoinhaberController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEditing = false; // New state variable for edit mode
  bool _isOnline = false; // New state variable for online status
  bool _dataLoadedOnce = false; // To track if data has been attempted to load

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _isOnline = false; // Assume offline until data is successfully fetched
    });

    try {
      final bankData = await apiService.fetchBankdaten(widget.webloginId);
      if (mounted) {
        setState(() {
          _dataLoadedOnce = true; // Mark that data loading attempt has occurred
          if (bankData.isNotEmpty) {
            _kontoinhaberController.text =
                bankData['KONTOINHABER']?.toString() ?? '';
            _ibanController.text = bankData['IBAN']?.toString() ?? '';
            _bicController.text = bankData['BIC']?.toString() ?? '';
            _isOnline = bankData['ONLINE'] as bool? ?? true;
          } else {
            LoggerService.logWarning(
              'No bank data found for webloginId: ${widget.webloginId}',
            );
            // If API returned empty data, but the API call itself was successful,
            // we still consider ourselves "online" to show an empty form or allow entry.
            // If 'ONLINE' was false here, it means a network error occurred.
            _isOnline = bankData['ONLINE'] as bool? ?? true;
          }
        });
      }
    } catch (error) {
      LoggerService.logError('Error fetching bank data: $error');
      if (mounted) {
        setState(() {
          _dataLoadedOnce = true; // Mark that data loading attempt has occurred
          _isOnline = false; // Set to offline on error
        });
        // We only show snackbar for network errors, not if just empty data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Bankdaten: $error'),
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

    LoggerService.logInfo('BankDataScreen initialized');
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from BankDataScreen');
    widget.onLogout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  /// Handles the action when the Floating Action Button is pressed.
  /// Toggles edit mode, or submits the form if currently in edit mode.
  Future<void> _handleFabPressed() async {
    if (_isLoading) {
      return; // Do nothing if already loading/submitting
    }

    if (_isEditing) {
      // If currently in edit mode, attempt to submit the form
      await _submitForm();
    } else {
      // If not in edit mode, switch to edit mode
      setState(() {
        _isEditing = true;
      });
      LoggerService.logInfo('Switched to edit mode.');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      LoggerService.logInfo('Form validation failed. Not submitting.');
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    bool registrationSuccess = false;

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
        registrationSuccess = true;
      } else {
        LoggerService.logError(
          'Failed to update bank data: Unexpected API response',
        );
        registrationSuccess = false;
      }
    } catch (error) {
      LoggerService.logError('Error updating bank data: $error');
      registrationSuccess = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Revert to read-only mode after submission attempt
          _isEditing = false;
        });
        // Navigate to result screen after submission attempt
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BankDataResultScreen(
              success: registrationSuccess,
              // Pass the required arguments from BankDataScreen's widget
              userData: widget.userData,
              isLoggedIn: widget.isLoggedIn,
              onLogout: widget.onLogout,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _kontoinhaberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading && !_dataLoadedOnce) {
      // Show loading indicator only initially, before first data attempt
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (!_isOnline) {
      // Show offline message if not online after initial load attempt
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 80,
              color: UIConstants.grey,
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Internet ist nicht zu Verfügung.',
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
                color: UIConstants.grey,
              ),
            ),
            const SizedBox(height: UIConstants.defaultSpacing / 2),
            Text(
              'Bitte überprüfen Sie Ihre Verbindung.',
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
          ],
        ),
      );
    } else {
      // Show the form if online and data loaded (or no data but online)
      bodyContent = Padding(
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
                  isReadOnly: !_isEditing, // Read-only based on _isEditing
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
                  isReadOnly: !_isEditing, // Read-only based on _isEditing
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
                  isReadOnly: !_isEditing, // Read-only based on _isEditing
                  validator: BankService.validateBIC,
                ),
                const SizedBox(height: UIConstants.defaultSpacing),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundGreen,
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
      body: bodyContent, // Use the dynamically determined body content
      // --- Floating Action Button (FAB) ---
      floatingActionButton: _isOnline
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _handleFabPressed,
              backgroundColor: UIConstants.defaultAppColor,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(UIConstants.white),
                    )
                  : Icon(
                      _isEditing
                          ? Icons.save // Show save icon when in edit mode
                          : Icons.edit, // Show edit icon when in read-only mode
                      color: UIConstants.white,
                      size: UIConstants.bodyFontSize + 4.0,
                    ),
            )
          : null, // Hide FAB if offline
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // ---
    );
  }

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
          ),
          floatingLabelBehavior:
              FloatingLabelBehavior.always, // Always show label for clarity
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
