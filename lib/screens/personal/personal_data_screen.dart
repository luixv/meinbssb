// In lib/screens/personal_data_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/screens/personal/personal_data_success_screen.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart'; // Ensure ScaledText is correctly implemented to use FontSizeProvider
import 'package:meinbssb/providers/font_size_provider.dart';

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

  Future<bool> _isOffline() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return !(await apiService.hasInternet());
    } catch (e) {
      LoggerService.logError('Error checking network status: $e');
      return true; // Assume offline if we can't check
    }
  }

  // --- Data Fetching and Population ---

  Future<void> _fetchAndPopulateData() async {
    final int? personId = widget.userData?.personId;

    if (personId == null || personId == 0) {
      // Added personId == 0 check
      LoggerService.logError(
        'Person ID is null or 0 in widget.userData. Cannot fetch personal data.',
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
        _geburtsdatumController.text = DateFormat(
          'dd.MM.yyyy',
        ).format(parsedDate);
      } catch (e) {
        LoggerService.logError('Error parsing date: ${data['GEBURTSDATUM']}');
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

  // --- Save Functionality ---
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final userDataToUpdate = UserData(
          personId: widget.userData?.personId ?? 0,
          webLoginId: widget.userData?.webLoginId ?? 0,
          passnummer:
              widget.userData?.passnummer ?? '', // Passnummer not editable
          vereinNr: widget.userData?.vereinNr ?? 0, // VereinNr not editable
          namen: _nachnameController.text,
          vorname: _vornameController.text,
          titel: _titelController.text,
          geburtsdatum:
              widget.userData?.geburtsdatum, // Geburtsdatum not editable
          geschlecht:
              _currentPassData?['GESCHLECHT'] is int
                  ? _currentPassData!['GESCHLECHT'] as int
                  : 0, // Geschlecht not editable from this screen
          vereinName:
              widget.userData?.vereinName ?? '', // VereinName not editable
          passdatenId:
              widget.userData?.passdatenId ?? 0, // PassdatenId not editable
          mitgliedschaftId:
              widget.userData?.mitgliedschaftId ??
              0, // MitgliedschaftId not editable
          strasse: _strasseHausnummerController.text,
          plz: _postleitzahlController.text,
          ort: _ortController.text,
          isOnline:
              widget.userData?.isOnline ?? false, // isOnline from initial fetch
        );

        final success = await apiService.updateKritischeFelderUndAdresse(
          userDataToUpdate,
        );

        if (mounted) {
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PersonalDataSuccessScreen(
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
  Widget build(BuildContext context) {
    // Access FontSizeProvider at the top level of the build method
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Persönliche Daten',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Semantics(
        label:
            'Persönliche Daten. Anzeige und Bearbeitung Ihrer persönlichen Informationen wie Name, Adresse, Geburtsdatum und Passnummer. Pflichtfelder und Hinweise werden angezeigt.',
        child:
            _isLoading && _currentPassData == null
                ? const Center(child: CircularProgressIndicator())
                : _buildPersonalDataForm(fontSizeProvider),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          // Hide FABs when offline
          if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
            return const SizedBox.shrink();
          }

          return _isEditing
              ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'personalDataCancelFab',
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _populateFields(_currentPassData!);
                      });
                    },
                    backgroundColor: UIConstants.defaultAppColor,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'personalDataSaveFab',
                    onPressed: _handleSave,
                    backgroundColor: UIConstants.defaultAppColor,
                    child: const Icon(Icons.save, color: Colors.white),
                  ),
                ],
              )
              : FloatingActionButton(
                heroTag: 'personalDataEditFab',
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                backgroundColor: UIConstants.defaultAppColor,
                child: const Icon(Icons.edit, color: Colors.white),
              );
        },
      ),
    );
  }

  Widget _buildTitelDropdown(FontSizeProvider fontSizeProvider) {
    final titelOptions = ['', 'Dr.', 'Dr. Dr.', 'Dr. hc.', 'Dr. Eh.'];
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
          child: DropdownButtonFormField<String>(
            value:
                titelOptions.contains(_titelController.text)
                    ? _titelController.text
                    : '',
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: 'Titel',
              labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
                fontSize:
                    UIStyles.formInputDecoration.labelStyle!.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              floatingLabelStyle: UIStyles
                  .formInputDecoration
                  .floatingLabelStyle
                  ?.copyWith(
                    fontSize:
                        UIStyles
                            .formInputDecoration
                            .floatingLabelStyle!
                            .fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              filled: true,
            ),
            items:
                titelOptions
                    .map(
                      (titel) => DropdownMenuItem<String>(
                        value: titel,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0.0,
                          ), // Minimum space
                          child: Text(
                            titel.isEmpty ? '(Kein Titel)' : titel,
                            style:
                                _isEditing
                                    ? UIStyles.formValueStyle.copyWith(
                                      fontSize:
                                          UIStyles.formValueStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    )
                                    : UIStyles.formValueBoldStyle.copyWith(
                                      fontSize:
                                          UIStyles
                                              .formValueBoldStyle
                                              .fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged:
                _isEditing
                    ? (value) {
                      setState(() {
                        _titelController.text = value ?? '';
                      });
                    }
                    : null,
            validator: (value) => null,
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isReadOnly = false,
    FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.always,
    Widget? suffixIcon,
  }) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
          child: TextFormField(
            controller: controller,
            style:
                isReadOnly
                    ? UIStyles.formValueBoldStyle.copyWith(
                      fontSize:
                          UIStyles.formValueBoldStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    )
                    : UIStyles.formValueStyle.copyWith(
                      fontSize:
                          UIStyles.formValueStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
            decoration: UIStyles.formInputDecoration.copyWith(
              labelText: label,
              labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
                fontSize:
                    UIStyles.formInputDecoration.labelStyle!.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              floatingLabelStyle: UIStyles
                  .formInputDecoration
                  .floatingLabelStyle
                  ?.copyWith(
                    fontSize:
                        UIStyles
                            .formInputDecoration
                            .floatingLabelStyle!
                            .fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
              floatingLabelBehavior: floatingLabelBehavior,
              hintText: isReadOnly ? null : label,
              hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
                fontSize:
                    UIStyles.formInputDecoration.hintStyle!.fontSize! *
                    fontSizeProvider.scaleFactor,
              ),
              filled: true,
              suffixIcon: suffixIcon,
            ),
            validator: validator,
            readOnly: isReadOnly,
          ),
        );
      },
    );
  }

  Widget _buildPersonalDataForm(FontSizeProvider fontSizeProvider) {
    final double scaledErrorFontSize =
        UIStyles.errorStyle.fontSize! * fontSizeProvider.scaleFactor;
    final double scaledBodyFontSize =
        UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor;

    return _errorMessage != null
        ? Center(
          child: ScaledText(
            _errorMessage!,
            style: UIStyles.errorStyle.copyWith(fontSize: scaledErrorFontSize),
          ),
        )
        : _currentPassData == null && !_isLoading
        ? Center(
          child: ScaledText(
            Messages.noPersonalDataAvailable,
            style: UIStyles.bodyStyle.copyWith(fontSize: scaledBodyFontSize),
          ),
        )
        : Padding(
          padding: UIConstants.defaultPadding,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: UIConstants.spacingS),
                  _buildTextField(
                    label: 'Passnummer',
                    controller: _passnummerController,
                    isReadOnly: true,
                  ),
                  _buildTextField(
                    label: 'Geburtsdatum',
                    controller: _geburtsdatumController,
                    isReadOnly: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: const Tooltip(
                      message:
                          'Eine Änderung des Geburtsdatums ist per Mail an schuetzenausweis@bssb.bayern möglich.',
                      triggerMode: TooltipTriggerMode.tap,
                      preferBelow: false,
                      child: Icon(
                        Icons.info_outline,
                        size: UIConstants.tooltipIconSize,
                      ),
                    ),
                  ),
                  _buildTitelDropdown(fontSizeProvider),
                  _buildTextField(
                    label: 'Vorname',
                    controller: _vornameController,
                    isReadOnly: !_isEditing,
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
                    isReadOnly: !_isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nachname ist erforderlich';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Straße und Hausnummer',
                    controller: _strasseHausnummerController,
                    isReadOnly: !_isEditing,
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
                    isReadOnly: !_isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Postleitzahl ist erforderlich';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'Ort',
                    controller: _ortController,
                    isReadOnly: !_isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ort ist erforderlich';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: UIConstants.spacingS),
                ],
              ),
            ),
          ),
        );
  }
}
