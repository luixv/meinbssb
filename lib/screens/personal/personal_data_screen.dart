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
      body:
          _isLoading && _currentPassData == null
              ? const Center(child: CircularProgressIndicator())
              : Semantics(
                label:
                    'Persönliche Daten Bildschirm. Anzeige und Bearbeitung Ihrer persönlichen Informationen wie Name, Adresse, Geburtsdatum und Passnummer.',
                liveRegion: true,
                child: Focus(
                  autofocus: true,
                  child: _buildPersonalDataForm(fontSizeProvider),
                ),
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
                  Semantics(
                    label: 'Abbrechen Button',
                    hint: 'Bearbeitung abbrechen und Änderungen verwerfen',
                    button: true,
                    child: FloatingActionButton(
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
                  ),
                  const SizedBox(height: 16),
                  _SaveButton(onPressed: _handleSave),
                ],
              )
              : _EditButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              );
        },
      ),
    );
  }

  Widget _buildTitelDropdown(FontSizeProvider fontSizeProvider) {
    final titelOptions = ['', 'Dr.', 'Dr. Dr.', 'Dr. hc.', 'Dr. Eh.'];
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return _DropdownWithKeyboardFocus(
          titelOptions: titelOptions,
          titelController: _titelController,
          isEditing: _isEditing,
          fontSizeProvider: fontSizeProvider,
          onChanged: (value) {
            setState(() {
              _titelController.text = value ?? '';
            });
          },
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
        return _TextFieldWithKeyboardFocus(
          label: label,
          controller: controller,
          validator: validator,
          isReadOnly: isReadOnly,
          floatingLabelBehavior: floatingLabelBehavior,
          suffixIcon: suffixIcon,
          fontSizeProvider: fontSizeProvider,
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
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Passnummer Eingabefeld',
                      hint: 'Dieses Feld ist nicht bearbeitbar.',
                      textField: true,
                      child: _buildTextField(
                        label: 'Passnummer',
                        controller: _passnummerController,
                        isReadOnly: true,
                      ),
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Geburtsdatum Eingabefeld',
                      hint: 'Dieses Feld ist nicht bearbeitbar.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Titel Auswahlfeld',
                      hint: 'Bitte wählen Sie Ihren Titel aus',
                      textField: true,
                      child: _buildTitelDropdown(fontSizeProvider),
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Vorname Eingabefeld',
                      hint: 'Bitte geben Sie Ihren Vornamen ein.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Nachname Eingabefeld',
                      hint: 'Bitte geben Sie Ihren Nachnamen ein.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Straße und Hausnummer Eingabefeld',
                      hint: 'Bitte geben Sie Ihre Straße und Hausnummer ein.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Postleitzahl Eingabefeld',
                      hint: 'Bitte geben Sie Ihre Postleitzahl ein.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  Focus(
                    canRequestFocus: true,
                    child: Semantics(
                      label: 'Ort Eingabefeld',
                      hint: 'Bitte geben Sie Ihren Wohnort ein.',
                      textField: true,
                      child: _buildTextField(
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
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingS),
                ],
              ),
            ),
          ),
        );
  }
}

// Custom Text Field with keyboard-only focus highlighting
class _TextFieldWithKeyboardFocus extends StatefulWidget {
  const _TextFieldWithKeyboardFocus({
    required this.label,
    required this.controller,
    required this.fontSizeProvider,
    this.validator,
    this.isReadOnly = false,
    this.floatingLabelBehavior = FloatingLabelBehavior.always,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final FontSizeProvider fontSizeProvider;
  final String? Function(String?)? validator;
  final bool isReadOnly;
  final FloatingLabelBehavior floatingLabelBehavior;
  final Widget? suffixIcon;

  @override
  State<_TextFieldWithKeyboardFocus> createState() => _TextFieldWithKeyboardFocusState();
}

class _TextFieldWithKeyboardFocusState extends State<_TextFieldWithKeyboardFocus> {
  bool _hasKeyboardFocus = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
      child: FocusableActionDetector(
        onShowFocusHighlight: (highlighted) {
          setState(() {
            _hasKeyboardFocus = highlighted;
          });
        },
        child: TextFormField(
          controller: widget.controller,
          style:
              widget.isReadOnly
                  ? UIStyles.formValueBoldStyle.copyWith(
                    fontSize:
                        UIStyles.formValueBoldStyle.fontSize! *
                        widget.fontSizeProvider.scaleFactor,
                  )
                  : UIStyles.formValueStyle.copyWith(
                    fontSize:
                        UIStyles.formValueStyle.fontSize! *
                        widget.fontSizeProvider.scaleFactor,
                  ),
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: widget.label,
            labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
              fontSize:
                  UIStyles.formInputDecoration.labelStyle!.fontSize! *
                  widget.fontSizeProvider.scaleFactor,
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
                      widget.fontSizeProvider.scaleFactor,
                ),
            floatingLabelBehavior: widget.floatingLabelBehavior,
            hintText: widget.isReadOnly ? null : widget.label,
            hintStyle: UIStyles.formInputDecoration.hintStyle?.copyWith(
              fontSize:
                  UIStyles.formInputDecoration.hintStyle!.fontSize! *
                  widget.fontSizeProvider.scaleFactor,
            ),
            filled: true,
            fillColor: _hasKeyboardFocus ? Colors.yellow.shade100 : null,
            focusedBorder: _hasKeyboardFocus
                ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.yellow.shade700,
                    width: 2.0,
                  ),
                )
                : null,
            suffixIcon: widget.suffixIcon,
          ),
          validator: widget.validator,
          readOnly: widget.isReadOnly,
        ),
      ),
    );
  }
}

// Custom Dropdown with keyboard-only focus highlighting
class _DropdownWithKeyboardFocus extends StatefulWidget {
  const _DropdownWithKeyboardFocus({
    required this.titelOptions,
    required this.titelController,
    required this.isEditing,
    required this.fontSizeProvider,
    required this.onChanged,
  });

  final List<String> titelOptions;
  final TextEditingController titelController;
  final bool isEditing;
  final FontSizeProvider fontSizeProvider;
  final void Function(String?) onChanged;

  @override
  State<_DropdownWithKeyboardFocus> createState() => _DropdownWithKeyboardFocusState();
}

class _DropdownWithKeyboardFocusState extends State<_DropdownWithKeyboardFocus> {
  bool _hasKeyboardFocus = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingS),
      child: FocusableActionDetector(
        onShowFocusHighlight: (highlighted) {
          setState(() {
            _hasKeyboardFocus = highlighted;
          });
        },
        child: DropdownButtonFormField<String>(
          value:
              widget.titelOptions.contains(widget.titelController.text)
                  ? widget.titelController.text
                  : '',
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: 'Titel',
            labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
              fontSize:
                  UIStyles.formInputDecoration.labelStyle!.fontSize! *
                  widget.fontSizeProvider.scaleFactor,
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
                      widget.fontSizeProvider.scaleFactor,
                ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: _hasKeyboardFocus ? Colors.yellow.shade100 : null,
            focusedBorder: _hasKeyboardFocus
                ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.yellow.shade700,
                    width: 2.0,
                  ),
                )
                : null,
          ),
          items:
              widget.titelOptions
                  .map(
                    (titel) => DropdownMenuItem<String>(
                      value: titel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                        ),
                        child: Text(
                          titel.isEmpty ? '(Kein Titel)' : titel,
                          style:
                              widget.isEditing
                                  ? UIStyles.formValueStyle.copyWith(
                                    fontSize:
                                        UIStyles.formValueStyle.fontSize! *
                                        widget.fontSizeProvider.scaleFactor,
                                  )
                                  : UIStyles.formValueBoldStyle.copyWith(
                                    fontSize:
                                        UIStyles
                                            .formValueBoldStyle
                                            .fontSize! *
                                        widget.fontSizeProvider.scaleFactor,
                                  ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: widget.isEditing ? widget.onChanged : null,
          validator: (value) => null,
        ),
      ),
    );
  }
}

// Custom Save Button widget with hover and focus support
class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.onPressed});
  
  final VoidCallback onPressed;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = (_isHovered || _isFocused) 
        ? Colors.black 
        : UIConstants.defaultAppColor;

    return Semantics(
      label: 'Speichern Button',
      hint: 'Änderungen speichern',
      button: true,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: FloatingActionButton(
            heroTag: 'personalDataSaveFab',
            onPressed: widget.onPressed,
            backgroundColor: backgroundColor,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Custom Edit Button widget with hover and focus support
class _EditButton extends StatefulWidget {
  const _EditButton({required this.onPressed});
  
  final VoidCallback onPressed;

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = (_isHovered || _isFocused) 
        ? Colors.black 
        : UIConstants.defaultAppColor;

    return Semantics(
      label: 'Bearbeiten Button',
      hint: 'Persönliche Daten bearbeiten',
      button: true,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: FloatingActionButton(
            heroTag: 'personalDataEditFab',
            onPressed: widget.onPressed,
            backgroundColor: backgroundColor,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
