// In lib/screens/personal_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/personal_data_result_screen.dart';
import '../services/core/logger_service.dart';
import '/services/api_service.dart';
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
  final TextEditingController _passnummerController = TextEditingController();
  final TextEditingController _geburtsdatumController = TextEditingController();
  final TextEditingController _titelController = TextEditingController();
  final TextEditingController _vornameController = TextEditingController();
  final TextEditingController _nachnameController = TextEditingController();
  final TextEditingController _strasseHausnummerController =
      TextEditingController();
  final TextEditingController _postleitzahlController = TextEditingController();
  final TextEditingController _ortController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _currentPassData;
  String? _errorMessage;
  bool _isEditing = false; // State variable for edit mode
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _fetchAndPopulateData();
  }

  Future<void> _fetchAndPopulateData() async {
    final int? personId = widget.userData['PERSONID'] as int?;

    if (personId == null) {
      LoggerService.logError(
        'Person ID is null in widget.userData. Cannot fetch personal data.',
      );
      if (mounted) {
        setState(() {
          _errorMessage = 'Person ID nicht verfügbar. Bitte erneut anmelden.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isOnline = false; // Reset online status when fetching
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.fetchPassdaten(personId);

      if (mounted) {
        setState(() {
          _currentPassData = response;
          // Extract and set the online status
          _isOnline = _currentPassData?['ONLINE'] as bool? ??
              false; // <-- Set _isOnline here
          _populateFields(
            _currentPassData!,
          );
        });
        LoggerService.logInfo(
          'Personal data fetched and fields populated successfully. Online status: $_isOnline',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Netzwerkfehler oder Server nicht erreichbar: $e';
        });
      }
      LoggerService.logError('Exception during _fetchAndPopulateData: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    _passnummerController.text = data['PASSNUMMER']?.toString() ?? '';
    if (data['GEBURTSDATUM'] != null &&
        data['GEBURTSDATUM'].toString().isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(data['GEBURTSDATUM'].toString());
        _geburtsdatumController.text =
            DateFormat('dd.MM.yyyy').format(parsedDate);
      } catch (e) {
        LoggerService.logError(
          'Error parsing date: ${data['GEBURTSDATUM']}',
        );
        _geburtsdatumController.text = 'Invalid Date';
      }
    } else {
      _geburtsdatumController.text = '';
    }
    _titelController.text = data['TITEL']?.toString() ?? '';
    _vornameController.text = data['VORNAME']?.toString() ?? '';
    _nachnameController.text = data['NAMEN']?.toString() ?? '';
    _strasseHausnummerController.text = data['STRASSE']?.toString() ?? '';
    _postleitzahlController.text = data['PLZ']?.toString() ?? '';
    _ortController.text = data['ORT']?.toString() ?? '';
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from PersonalDataScreen');
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

    bool updateSuccess = false;
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final int? personId = widget.userData['PERSONID'] as int?;

      if (personId == null) {
        LoggerService.logError(
          'Person ID is null for update. Cannot submit form.',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fehler: Person ID nicht verfügbar. Bitte erneut anmelden.',
              ),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
        updateSuccess = false;
      } else {
        updateSuccess = await apiService.updateKritischeFelderUndAdresse(
          personId,
          _titelController.text,
          _nachnameController.text,
          _vornameController.text,
          _currentPassData?['GESCHLECHT'] as int? ?? 0,
          _strasseHausnummerController.text,
          _postleitzahlController.text,
          _ortController.text,
        );

        if (updateSuccess) {
          LoggerService.logInfo(
            'Personal data updated successfully. Re-fetching new data...',
          );
          await _fetchAndPopulateData(); // Re-fetch to confirm update and populate with fresh data
          if (mounted) {
            setState(() {
              _isEditing = false; // Exit edit mode on successful submission
            });
          }
        } else {
          LoggerService.logError('Failed to update personal data.');
        }
      }
    } catch (error) {
      LoggerService.logError('Exception during personal data update: $error');
      updateSuccess = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to result screen after submission attempt
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PersonDataResultScreen(
              success: updateSuccess,
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
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Persönliche Daten',
          style: UIConstants.appBarTitleStyle,
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: UIConstants.defaultHorizontalPadding),
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
      body: _isLoading && _currentPassData == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: UIConstants.errorMessageStyle))
              : _currentPassData == null && !_isLoading
                  ? const Center(
                      child: Text('Keine persönlichen Daten verfügbar.'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(UIConstants.defaultPadding),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: UIConstants.defaultSpacing,
                              ),
                              // Read-only fields with FloatingLabelBehavior.always for clarity
                              _buildTextField(
                                label: 'Passnummer',
                                controller: _passnummerController,
                                isReadOnly: true, // Always read-only
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Geburtsdatum',
                                controller: _geburtsdatumController,
                                isReadOnly: true, // Always read-only
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                inputTextStyle: UIConstants.formValueStyle,
                                suffixIcon: Tooltip(
                                  message:
                                      'Eine Änderung des Geburtsdatums ist per Mail an schuetzenausweis@bssb.bayern möglich.',
                                  preferBelow: false,
                                  child: Icon(
                                    Icons.info_outline,
                                    size: UIConstants.subtitleStyle.fontSize,
                                  ),
                                ),
                              ),
                              // Editable fields will now depend on _isEditing
                              _buildTextField(
                                label: 'Titel',
                                controller: _titelController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                validator: (value) => null,
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Vorname',
                                controller: _vornameController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vorname ist erforderlich';
                                  }
                                  return null;
                                },
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Nachname',
                                controller: _nachnameController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nachname ist erforderlich';
                                  }
                                  return null;
                                },
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Straße + Hausnummer',
                                controller: _strasseHausnummerController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Straße und Hausnummer sind erforderlich';
                                  }
                                  return null;
                                },
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Postleitzahl',
                                controller: _postleitzahlController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Postleitzahl ist erforderlich';
                                  }
                                  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                                    return 'Ungültige Postleitzahl';
                                  }
                                  return null;
                                },
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              _buildTextField(
                                label: 'Ort',
                                controller: _ortController,
                                isReadOnly:
                                    !_isEditing, // Read-only if not editing
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ort ist erforderlich';
                                  }
                                  return null;
                                },
                                inputTextStyle: UIConstants.formValueStyle,
                              ),
                              const SizedBox(
                                height: UIConstants.defaultSpacing,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
      // ---
      // Modified Floating Action Button
      floatingActionButton: _isOnline // <-- Conditionally render FAB
          ? FloatingActionButton(
              onPressed:
                  _isLoading ? null : _handleFabPressed, // Call the new handler
              backgroundColor: UIConstants.defaultAppColor,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        UIConstants.circularProgressIndicator,
                      ),
                    )
                  : Icon(
                      _isEditing
                          ? Icons.save
                          : Icons.edit, // Icon changes based on mode
                      color: UIConstants.saveEditIcon,
                    ),
            )
          : null, // <-- Render nothing if offline
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // ---
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
    TextStyle? inputTextStyle,
    Color? backgroundColor,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    // Determine the text style based on mode and read-only status
    TextStyle effectiveTextStyle;
    if (!isReadOnly) {
      // Editable fields: default style or you can customize further
      effectiveTextStyle = inputTextStyle ??
          const TextStyle(
            fontSize: UIConstants.bodyFontSize,
          );
    } else {
      // Read-only fields: bold if in view mode
      effectiveTextStyle = inputTextStyle ??
          const TextStyle(
            fontSize: UIConstants.bodyFontSize,
            fontWeight: FontWeight.bold,
          );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.defaultSpacing),
      child: TextFormField(
        controller: controller,
        style: effectiveTextStyle,
        decoration: UIConstants.defaultInputDecoration.copyWith(
          labelText: label,
          floatingLabelBehavior: floatingLabelBehavior,
          hintText: isReadOnly ? null : label,
          fillColor: backgroundColor,
          filled: backgroundColor != null,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        readOnly: isReadOnly,
        keyboardType: keyboardType,
      ),
    );
  }
}
