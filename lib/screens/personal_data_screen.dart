// In lib/screens/personal_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/personal_data_result_screen.dart';
import '/services/core/logger_service.dart';
import '/services/api_service.dart';
import 'package:intl/intl.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class PersonDataScreen extends StatefulWidget {
  const PersonDataScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
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
    final int? personId = widget.userData?.personId;

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
          _currentPassData = response?.toJson();
          // Extract and set the online status
          _isOnline = response?.isOnline ?? false;
          if (response != null) {
            _populateFields(response.toJson());
          }
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

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final userData = UserData(
          personId: widget.userData?.personId ?? 0,
          webLoginId: widget.userData?.webLoginId ?? 0,
          passnummer: widget.userData?.passnummer ?? '',
          vereinNr: widget.userData?.vereinNr ?? 0,
          namen: _nachnameController.text,
          vorname: _vornameController.text,
          titel: _titelController.text,
          geburtsdatum: widget.userData?.geburtsdatum,
          geschlecht: _currentPassData?['GESCHLECHT'] is int
              ? _currentPassData!['GESCHLECHT'] as int
              : 0,
          vereinName: widget.userData?.vereinName ?? '',
          passdatenId: widget.userData?.passdatenId ?? 0,
          mitgliedschaftId: widget.userData?.mitgliedschaftId ?? 0,
          strasse: _strasseHausnummerController.text,
          plz: _postleitzahlController.text,
          ort: _ortController.text,
          isOnline: widget.userData?.isOnline ?? false,
        );

        final success =
            await apiService.updateKritischeFelderUndAdresse(userData);

        if (mounted) {
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalDataResultScreen(
                  success: true,
                  userData: widget.userData,
                  isLoggedIn: widget.isLoggedIn,
                  onLogout: widget.onLogout,
                ),
              ),
            );
          } else {
            setState(() {
              _errorMessage = 'Fehler beim Speichern der Daten';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Fehler beim Speichern der Daten: $e';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isEditing = false;
          });
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
    return BaseScreenLayout(
      title: 'Persönliche Daten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: _isLoading && _currentPassData == null
          ? const Center(child: CircularProgressIndicator())
          : _buildPersonalDataForm(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isEditing
            ? _handleSave
            : () {
                setState(() {
                  _isEditing = true;
                });
              },
        backgroundColor: UIConstants.defaultAppColor,
        child: Icon(
          _isEditing ? Icons.save : Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPersonalDataForm() {
    return _errorMessage != null
        ? Center(
            child: Text(
              _errorMessage!,
            ),
          )
        : _currentPassData == null && !_isLoading
            ? const Center(
                child: Text('Keine persönlichen Daten verfügbar.'),
              )
            : Padding(
                padding: UIConstants.defaultPadding,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: UIConstants.spacingS,
                        ),
                        _buildTextField(
                          labelText: 'Passnummer',
                          controller: _passnummerController,
                          enabled: false,
                        ),
                        _buildTextField(
                          labelText: 'Geburtsdatum',
                          controller: _geburtsdatumController,
                          enabled: false,
                          validator: (value) => null,
                          suffixIcon: Tooltip(
                            message:
                                'Eine Änderung des Geburtsdatums ist per Mail an schuetzenausweis@bssb.bayern möglich.',
                            preferBelow: false,
                            child: Icon(
                              Icons.info_outline,
                              size: UIStyles.subtitleStyle.fontSize,
                            ),
                          ),
                        ),
                        _buildTextField(
                          labelText: 'Titel',
                          controller: _titelController,
                          enabled: !_isEditing,
                          validator: (value) => null,
                        ),
                        _buildTextField(
                          labelText: 'Vorname',
                          controller: _vornameController,
                          enabled: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vorname ist erforderlich';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          labelText: 'Nachname',
                          controller: _nachnameController,
                          enabled: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nachname ist erforderlich';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          labelText: 'Straße und Hausnummer',
                          controller: _strasseHausnummerController,
                          enabled: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Straße und Hausnummer sind erforderlich';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          labelText: 'Postleitzahl',
                          controller: _postleitzahlController,
                          enabled: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Postleitzahl ist erforderlich';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          labelText: 'Ort',
                          controller: _ortController,
                          enabled: !_isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ort ist erforderlich';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: UIConstants.spacingS,
                        ),
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = true,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        final scaledStyle = TextStyle(
          fontSize: UIConstants.bodyFontSize * fontSizeProvider.scaleFactor,
        );
        return TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: labelText,
            labelStyle: scaledStyle,
            suffixIcon: suffixIcon,
          ),
          style: scaledStyle,
        );
      },
    );
  }
}
