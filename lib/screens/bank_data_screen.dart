import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '../services/core/logger_service.dart';
import '/services/api/bank_service.dart';
import '/services/api_service.dart' hide NetworkException;
import '/screens/bank_data_result_screen.dart';
import '/exceptions/network_exception.dart';

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
      _isOnline =
          true; // Assume online initially, will be set to false if NetworkException occurs
      _dataLoadedOnce = false; // Reset for a new load attempt
    });

    try {
      final bankData = await apiService.fetchBankdaten(widget.webloginId);
      if (mounted) {
        setState(() {
          _dataLoadedOnce = true; // Mark that data loading attempt has occurred

          // Populate controllers regardless of whether data is truly "empty" or not.
          // If bankData is {'ONLINE': true}, these will become empty strings.
          _kontoinhaberController.text =
              bankData['KONTOINHABER']?.toString() ?? '';
          _ibanController.text = bankData['IBAN']?.toString() ?? '';
          _bicController.text = bankData['BIC']?.toString() ?? '';

          // Determine _isOnline status based on the API response's 'ONLINE' flag
          _isOnline = bankData['ONLINE'] as bool? ??
              true; // Default to true if not present

          // Determine _isEditing: if any key fields are empty, go to edit mode
          if (_kontoinhaberController.text.isEmpty &&
              _ibanController.text.isEmpty &&
              _bicController.text.isEmpty) {
            _isEditing = true; // No data found, allow editing
            LoggerService.logInfo(
              'No bank data found, switching to edit mode.',
            );
          } else {
            _isEditing = false; // Data found, stay in read-only
            LoggerService.logInfo(
              'Bank data loaded, staying in read-only mode.',
            );
          }
        });
      }
    } catch (error) {
      LoggerService.logError('Error fetching bank data: $error');
      if (mounted) {
        setState(() {
          _dataLoadedOnce = true; // Mark that data loading attempt has occurred
          // The crucial change: only set _isOnline to false if it's a genuine NetworkException
          if (error is NetworkException) {
            _isOnline = false; // Genuine network error, so go offline
            LoggerService.logWarning(
              'Network error during bank data fetch, showing offline message.',
            );
          } else {
            // Any other error (e.g., server returned 404, or malformed data that wasn't a NetworkException)
            // We assume the network is available, but no data was found or there was an issue with the data itself.
            _isOnline = true; // Assume online for non-network errors
            _isEditing =
                true; // Allow editing if data couldn't be loaded/parsed
            _kontoinhaberController
                .clear(); // Ensure fields are clear for new input
            _ibanController.clear();
            _bicController.clear();
            LoggerService.logWarning(
              'Non-network error during bank data fetch, switching to edit mode.',
            );
          }
        });
        // Show snackbar for all errors during load, as a fallback message
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

  Future<void> _handleDeleteBankData() async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: Text(
              'Bankdaten löschen',
              style: TextStyle(
                color: UIConstants.defaultAppColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
                color: UIConstants.tableContentColor,
              ),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Sind Sie sicher, dass Sie Ihre Bankdaten ',
                ),
                TextSpan(
                  text: _ibanController.text, // Show the IBAN for confirmation
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
                horizontal: UIConstants.defaultPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.cancelButtonBackground,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: UIConstants.closeIcon),
                          SizedBox(width: 8),
                          Text(
                            'Abbrechen',
                            style:
                                TextStyle(color: UIConstants.cancelButtonText),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants
                            .deleteIcon, // Use delete color for confirm
                        padding: UIConstants.buttonPadding,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                          ), // Delete icon on confirm button
                          SizedBox(width: 8),
                          Text(
                            'Löschen',
                            style:
                                TextStyle(color: UIConstants.deleteButtonText),
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

    if (confirmDelete != true) return; // If cancelled, do nothing

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final success = await apiService.deleteBankdaten(widget.webloginId);
      if (mounted) {
        if (success) {
          LoggerService.logInfo(
            'Bank data deleted successfully for webloginId: ${widget.webloginId}',
          );
          // Clear fields and reset state to reflect deletion
          _kontoinhaberController.clear();
          _ibanController.clear();
          _bicController.clear();
          setState(() {
            _isEditing = true; // Allow new data entry after deletion
            _isOnline =
                true; // Assume online since deletion was successful via API
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bankdaten erfolgreich gelöscht.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        } else {
          LoggerService.logError(
            'Failed to delete bank data: API returned unsuccessful.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Löschen der Bankdaten.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Error deleting bank data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
              color: UIConstants.greySubtitleText,
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Internet ist nicht zu Verfügung.',
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
                color: UIConstants.greySubtitleText,
              ),
            ),
            const SizedBox(height: UIConstants.defaultSpacing / 2),
            Text(
              'Bitte überprüfen Sie Ihre Verbindung.',
              style: UIConstants.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleText),
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
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end, // Align FABs to the right
        children: [
          // Existing Edit/Save FAB
          _isOnline
              ? FloatingActionButton(
                  heroTag: 'editSaveFab', // Important for multiple FABs
                  onPressed: _isLoading ? null : _handleFabPressed,
                  backgroundColor: UIConstants.defaultAppColor,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIConstants.circularProgressIndicator,
                          ),
                        )
                      : Icon(
                          _isEditing
                              ? Icons.save // Show save icon when in edit mode
                              : Icons
                                  .edit, // Show edit icon when in read-only mode
                          color: UIConstants.saveEditIcon,
                          size: UIConstants.bodyFontSize + 4.0,
                        ),
                )
              : const SizedBox.shrink(), // Hide if offline

          // Spacing between FABs (only if both are potentially visible)
          if (_isOnline &&
              !_isEditing &&
              _kontoinhaberController.text.isNotEmpty)
            const SizedBox(height: 16),

          // New Delete FAB
          (_isOnline && !_isEditing && _kontoinhaberController.text.isNotEmpty)
              ? FloatingActionButton(
                  heroTag: 'deleteFab', // Important for multiple FABs
                  onPressed:
                      _isLoading ? null : _handleDeleteBankData, // New handler
                  backgroundColor:
                      UIConstants.deleteIcon, // Use a delete-appropriate color
                  child:
                      _isLoading // If global isLoading, might want specific delete loading state
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Icon(
                              Icons.delete_forever, // Stronger delete icon
                              color: Colors.white,
                            ),
                )
              : const SizedBox
                  .shrink(), // Hide if offline, or in editing mode, or no data
        ],
      ),
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
    // Determine the effective text style
    TextStyle effectiveTextStyle;
    if (!_isEditing) {
      effectiveTextStyle = inputTextStyle ??
          const TextStyle(
            fontSize: UIConstants.bodyFontSize,
            fontWeight: FontWeight.bold,
          );
    } else {
      effectiveTextStyle = inputTextStyle ??
          TextStyle(
            fontSize: UIConstants.bodyFontSize,
            fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal,
          );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        controller: controller,
        style: effectiveTextStyle,
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: UIConstants.subtitleFontSize,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
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
