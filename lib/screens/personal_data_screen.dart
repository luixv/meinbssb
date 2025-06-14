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
      title: UIConstants.personalDataTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: UIConstants.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      ScaledText(
                        _errorMessage!,
                        style: UIStyles.errorStyle,
                      ),
                    const SizedBox(height: UIConstants.spacingM),
                    const ScaledText(
                      UIConstants.personalDataSubtitle,
                      style: UIStyles.subtitleStyle,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildPassnummerField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildGeburtsdatumField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildTitelField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildVornameField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildNachnameField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildStrasseHausnummerField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildPostleitzahlField(),
                    const SizedBox(height: UIConstants.spacingS),
                    _buildOrtField(),
                    const SizedBox(height: UIConstants.spacingM),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
      floatingActionButtons: [
        FloatingActionButton(
          key: const Key('helpFab'),
          onPressed: () {
            Navigator.pushNamed(context, '/help');
          },
          backgroundColor: _appColor,
          child: const Icon(Icons.help_outline),
        ),
        FloatingActionButton(
          key: const Key('settingsFab'),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          backgroundColor: _appColor,
          child: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _buildPassnummerField() {
    return TextField(
      key: const Key('passnummerField'),
      controller: _passnummerController,
      enabled: false,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Passnummer',
      ),
    );
  }

  Widget _buildGeburtsdatumField() {
    return TextField(
      key: const Key('geburtsdatumField'),
      controller: _geburtsdatumController,
      enabled: false,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Geburtsdatum',
      ),
    );
  }

  Widget _buildTitelField() {
    return TextField(
      key: const Key('titelField'),
      controller: _titelController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Titel',
      ),
    );
  }

  Widget _buildVornameField() {
    return TextField(
      key: const Key('vornameField'),
      controller: _vornameController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Vorname',
      ),
    );
  }

  Widget _buildNachnameField() {
    return TextField(
      key: const Key('nachnameField'),
      controller: _nachnameController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Nachname',
      ),
    );
  }

  Widget _buildStrasseHausnummerField() {
    return TextField(
      key: const Key('strasseHausnummerField'),
      controller: _strasseHausnummerController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Straße und Hausnummer',
      ),
    );
  }

  Widget _buildPostleitzahlField() {
    return TextField(
      key: const Key('postleitzahlField'),
      controller: _postleitzahlController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Postleitzahl',
      ),
    );
  }

  Widget _buildOrtField() {
    return TextField(
      key: const Key('ortField'),
      controller: _ortController,
      enabled: _isEditing,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Ort',
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('saveButton'),
        onPressed: _isLoading ? null : _handleSave,
        style: UIStyles.defaultButtonStyle,
        child: _isLoading
            ? UIConstants.defaultLoadingIndicator
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: UIConstants.spacingS),
                  ScaledText(
                    'Speichern',
                    style: UIStyles.buttonStyle,
                  ),
                ],
              ),
      ),
    );
  }
}
