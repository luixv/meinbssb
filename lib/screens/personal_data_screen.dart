// In lib/screens/personal_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/personal_data_result_screen.dart';
import '/services/logger_service.dart';
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

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic> _userData = {}; // Local state for user data

  @override
  void initState() {
    super.initState();
    _userData =
        widget.userData['data'] ?? {}; // Initialize from widget.userData
    _loadInitialData();
  }

  // Helper to load and populate fields from _userData
  void _populateFields() {
    _passnummerController.text = _userData['PASSNUMMER']?.toString() ?? '';
    if (_userData['GEBURTSDATUM'] != null) {
      try {
        final parsedDate = DateTime.parse(_userData['GEBURTSDATUM']);
        _geburtsdatumController.text =
            DateFormat('dd.MM.yyyy').format(parsedDate);
      } catch (e) {
        LoggerService.logError(
          'Error parsing date: ${_userData['GEBURTSDATUM']}',
        );
        _geburtsdatumController.text = 'Invalid Date';
      }
    } else {
      _geburtsdatumController.text = '';
    }
    _titelController.text = _userData['TITEL']?.toString() ?? '';
    _vornameController.text = _userData['VORNAME']?.toString() ?? '';
    _nachnameController.text = _userData['NAMEN']?.toString() ?? '';
    _strasseHausnummerController.text = _userData['STRASSE']?.toString() ?? '';
    _postleitzahlController.text = _userData['PLZ']?.toString() ?? '';
    _ortController.text = _userData['ORT']?.toString() ?? '';
    LoggerService.logInfo('Personal data fields populated.');
  }

  void _loadInitialData() {
    _populateFields(); // Call this once in initState
    LoggerService.logInfo('KontaktdatenScreen initialized');
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from KontaktdatenScreen');
    widget.onLogout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool updateSuccess = false;
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final int personId = widget.userData['data']['PERSONID'];

        updateSuccess = await apiService.updateKritischeFelderUndAdresse(
          personId,
          _titelController.text,
          _nachnameController.text,
          _vornameController.text,
          _userData['GESCHLECHT'] ?? 0, // Placeholder, ideally from UI
          _strasseHausnummerController.text,
          _postleitzahlController.text,
          _ortController.text,
        );

        if (updateSuccess) {
          LoggerService.logInfo(
            'Personal data updated successfully. Fetching new data...',
          );
          // *** Crucial step: Re-fetch updated personal data ***
          final updatedData = await apiService.fetchPassdaten(personId);
          if (mounted) {
            setState(() {
              _userData =
                  updatedData['data']; // Update local _userData with fresh data
            });
            _populateFields(); // Repopulate fields with new data
            LoggerService.logInfo(
              'Personal data re-fetched and fields updated.',
            );
          } else {
            LoggerService.logError(
              'Failed to re-fetch personal data after update.',
            );
            updateSuccess = false; // Treat re-fetch failure as overall failure
          }
        }
      } catch (error) {
        LoggerService.logError(
          'Exception during personal data update or re-fetch: $error',
        );
        updateSuccess = false;
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to result screen after operation (success or failure)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PersonDataResultScreen(
                success: updateSuccess,
                userData: widget
                    .userData, // Pass the original widget.userData (or ideally, the new _userData)
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
              ),
            ),
          );
        }
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
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Persönliche Daten',
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
                  label: 'Passnummer',
                  controller: _passnummerController,
                  isReadOnly: true,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  inputTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTextField(
                  label: 'Geburtsdatum',
                  controller: _geburtsdatumController,
                  isReadOnly: true,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  inputTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: Tooltip(
                    message:
                        'Eine Änderung des Geburtsdatums ist per Mail an schuetzenausweis@bssb.bayern möglich.',
                    preferBelow: false,
                    child: Icon(
                      Icons.info_outline,
                      size: UIConstants.subtitleStyle.fontSize,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildTextField(
                  label: 'Titel',
                  controller: _titelController,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  validator: (value) {
                    return null;
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto,
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
          floatingLabelBehavior: floatingLabelBehavior,
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
