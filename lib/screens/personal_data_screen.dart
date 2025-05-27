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
  // Removed personId from here, as it will be accessed from userData
  const PersonDataScreen(
    this.userData, {
    // userData is the first positional argument, implicitly named
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final Map<String, dynamic> userData; // This map now contains 'PERSONID'
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
  Map<String, dynamic>?
      _currentPassData; // Stores the fresh data fetched from API
  String? _errorMessage; // To show if initial fetch fails

  @override
  void initState() {
    super.initState();
    // Fetch fresh data when the screen initializes
    _fetchAndPopulateData();
  }

  // Method to fetch data from API and populate the form fields
  Future<void> _fetchAndPopulateData() async {
    // Get personId directly from widget.userData
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
      _errorMessage = null; // Clear any previous error
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService
          .fetchPassdaten(personId); // Use personId from userData

      if (response['data'] != null) {
        if (mounted) {
          setState(() {
            _currentPassData = response['data'] as Map<String, dynamic>;
            _populateFields(
              _currentPassData!,
            ); // Populate fields with the new data
          });
          LoggerService.logInfo(
            'Personal data fetched and fields populated successfully.',
          );
        }
      } else {
        final message = response['ResultMessage'] ??
            'Unbekannter Fehler beim Laden der Daten.';
        if (mounted) {
          setState(() {
            _errorMessage = 'Fehler beim Laden: $message';
          });
        }
        LoggerService.logError('Failed to fetch personal data: $message');
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

  // Helper to populate fields from a Map<String, dynamic>
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
    _nachnameController.text =
        data['NAMEN']?.toString() ?? ''; // Use 'NAMEN' for Nachname
    _strasseHausnummerController.text = data['STRASSE']?.toString() ?? '';
    _postleitzahlController.text = data['PLZ']?.toString() ?? '';
    _ortController.text = data['ORT']?.toString() ?? '';
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from PersonalDataScreen');
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
        final int? personId = widget.userData['PERSONID']
            as int?; // Get personId from userData again

        if (personId == null) {
          LoggerService.logError(
            'Person ID is null for update. Cannot submit form.',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fehler: Person ID nicht verfügbar. Bitte erneut anmelden.',
              ),
              duration: UIConstants.snackBarDuration,
            ),
          );
          updateSuccess = false;
        } else {
          updateSuccess = await apiService.updateKritischeFelderUndAdresse(
            personId, // Use personId from userData
            _titelController.text,
            _nachnameController.text,
            _vornameController.text,
            _currentPassData?['GESCHLECHT'] as int? ??
                0, // Get gender from the fetched map
            _strasseHausnummerController.text,
            _postleitzahlController.text,
            _ortController.text,
          );

          if (updateSuccess) {
            LoggerService.logInfo(
              'Personal data updated successfully. Re-fetching new data...',
            );
            // Re-fetch updated data to ensure the form displays the latest state
            await _fetchAndPopulateData(); // Call the same fetch method
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
          // Navigate to result screen after operation (success or failure)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PersonDataResultScreen(
                success: updateSuccess,
                userData: widget
                    .userData, // Pass original widget.userData for menu/consistency
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
            userData: widget
                .userData, // Pass the original widget.userData to the menu
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      body: _isLoading &&
              _currentPassData ==
                  null // Show loading indicator only on initial load
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _currentPassData == null &&
                      !_isLoading // No data and not loading
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
                              _buildTextField(
                                label: 'Passnummer',
                                controller: _passnummerController,
                                isReadOnly: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                inputTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildTextField(
                                label: 'Geburtsdatum',
                                controller: _geburtsdatumController,
                                isReadOnly: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                validator: (value) => null,
                              ),
                              _buildTextField(
                                label: 'Vorname',
                                controller: _vornameController,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
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
                              ),
                              _buildTextField(
                                label: 'Ort',
                                controller: _ortController,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ort ist erforderlich';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: UIConstants.defaultSpacing,
                              ),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
      ),
    );
  }
}
