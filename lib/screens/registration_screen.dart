// Project: Mein BSSB
// Filename: registration_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/logo_widget.dart';
import '/screens/privacy_screen.dart';
import '/screens/registration_success_screen.dart';
import '/services/api/auth_service.dart';
import '../services/core/email_service.dart';
import '../services/core/error_service.dart';
import '../services/core/logger_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    required this.authService,
    required this.emailService,
    super.key,
  });
  final AuthService authService;
  final EmailService emailService;

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  DateTime? _selectedDate;
  bool _privacyAccepted = false;
  String? zipCodeError;
  String? passNumberError;
  String? emailError;
  bool _isLoading = false;
  String _successMessage = '';
  Map<String, dynamic> userData = {};
  final FocusNode _emailFocusNode = FocusNode(); // Add a FocusNode
  bool _emailFieldTouched = false; // New flag

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get passNumberController => _passNumberController;
  TextEditingController get emailController => _emailController;
  TextEditingController get zipCodeController => _zipCodeController;
  DateTime? get selectedDate => _selectedDate;
  bool get privacyAccepted => _privacyAccepted;

  @override
  void initState() {
    super.initState();
    zipCodeError = null;
    passNumberError = null;
    emailError = null;
    _emailFieldTouched = false;
    _emailFocusNode.addListener(
      _onEmailFocusChanged,
    ); // Listen for focus changes
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _emailFocusNode.dispose(); // Dispose of the FocusNode
    super.dispose();
  }

  void _onEmailFocusChanged() {
    if (!_emailFocusNode.hasFocus) {
      setState(() {
        _emailFieldTouched = true;
        validateEmail(_emailController.text);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('de', 'DE'),
      helpText: 'Geburtsdatum',
      cancelText: 'Abbrechen',
      confirmText: 'Auswählen',
      fieldLabelText: 'Geburtsdatum eingeben',
      fieldHintText: 'TT.MM.JJJJ',
      errorFormatText: 'Ungültiges Datumsformat.',
      errorInvalidText: 'Ungültiges Datum.',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: UIConstants.defaultAppColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: UIConstants.sendButtonText,
                backgroundColor: UIConstants.acceptButtonBackground,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool validateEmail(String value) {
    if (!_emailFieldTouched && value.isEmpty) {
      emailError = null; // Don't show error if not touched and empty
      return true;
    }
    if (value.isEmpty) {
      emailError = ErrorService.handleValidationError(
        'E-Mail',
        'E-Mail ist erforderlich.',
      );
      return false;
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      emailError = ErrorService.handleValidationError(
        'E-Mail',
        'Bitte geben Sie eine gültige E-Mail Adresse ein.',
      );
      return false;
    }
    emailError = null;
    return true;
  }

  bool validateZipCode(String value) {
    if (value.isEmpty) {
      zipCodeError = ErrorService.handleValidationError(
        'Postleitzahl',
        'Postleitzahl ist erforderlich.',
      );
    } else if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      zipCodeError = ErrorService.handleValidationError(
        'Postleitzahl',
        'Postleitzahl muss 5 Ziffern enthalten.',
      );
    } else {
      zipCodeError = null;
    }
    return zipCodeError == null;
  }

  bool validatePassNumber(String value) {
    if (value.isEmpty) {
      passNumberError = ErrorService.handleValidationError(
        'Schützenausweisnummer',
        'Schützenausweisnummer ist erforderlich.',
      );
    } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      passNumberError = ErrorService.handleValidationError(
        'Schützenausweisnummer',
        'Schützenausweisnummer muss 8 Ziffern enthalten.',
      );
    } else {
      passNumberError = null;
    }
    return passNumberError == null;
  }

  bool isFormValid() {
    final isZipValid = _zipCodeController.text.isNotEmpty
        ? validateZipCode(_zipCodeController.text)
        : true;
    final isPassValid = _passNumberController.text.isNotEmpty
        ? validatePassNumber(_passNumberController.text)
        : true;
    final isDateValid =
        _selectedDate != null && _selectedDate!.isBefore(DateTime.now());
    final isEmailValid = validateEmail(_emailController.text);

    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        isEmailValid &&
        isZipValid &&
        isPassValid &&
        isDateValid &&
        _privacyAccepted;
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _successMessage = '';
    });

    await Future.delayed(UIConstants.loadingDelay);

    if (_selectedDate == null || !_selectedDate!.isBefore(DateTime.now())) {
      if (mounted) {
        ErrorService.showErrorSnackBar(
          context,
          'Bitte wählen Sie ein gültiges Geburtsdatum in der Vergangenheit.',
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      final response = await widget.authService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        passNumber: _passNumberController.text,
        email: _emailController.text,
        birthDate: formattedDate,
        zipCode: _zipCodeController.text,
      );

      if (response['ResultType'] == 1) {
        LoggerService.logInfo(
          "Registration successful: ${response['ResultMessage']}",
        );
        bool emailSent = false;

        try {
          await _sendRegistrationEmail();
          emailSent = true;
        } catch (e) {
          LoggerService.logError('Email sending error: $e');
          if (mounted) {
            ErrorService.showErrorSnackBar(
              context,
              'Registrierung fehlgeschlagen! Bitte versuchen Sie es später noch einmal.',
            );
          }
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationSuccessScreen(
                message: emailSent
                    ? 'Registrierung erfolgreich!'
                    : 'Registrierung nicht erfolgreich! versuchen Sie es später erneut.',
                userData: userData,
              ),
            ),
          );
        }
      } else {
        LoggerService.logError(
          "Registration failed: ${response['ResultMessage']}",
        );
        if (mounted) {
          ErrorService.showErrorSnackBar(
            context,
            ErrorService.formatApiError(response),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Error during registration: $e');
      if (mounted) {
        ErrorService.showErrorSnackBar(
          context,
          ErrorService.handleNetworkError(e),
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

  Future<void> _sendRegistrationEmail() async {
    try {
      final fromEmail = await widget.emailService.getFromEmail();
      final subject = await widget.emailService.getRegistrationSubject();
      final registrationContent =
          await widget.emailService.getRegistrationContent();

      if (fromEmail == null || subject == null || registrationContent == null) {
        LoggerService.logWarning(
          'Registration email content not fully configured.',
        );
        return;
      }

      final emailResponse = await widget.emailService.sendEmail(
        from: fromEmail,
        recipient: _emailController.text,
        subject: subject,
        body: registrationContent,
      );

      if (emailResponse['ResultType'] != 1) {
        throw Exception(emailResponse['ResultMessage']);
      }
    } catch (e) {
      LoggerService.logError('Error sending email: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text('Registrierung', style: UIConstants.titleStyle),
        actions: [
          // --- Added ConnectivityIcon here ---
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(),
          ),
          // --- End ConnectivityIcon addition ---
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: false,
            onLogout: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        color: UIConstants.backgroundColor,
        child: SingleChildScrollView(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              const SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Hier Registrieren',
                style: UIConstants.headerStyle.copyWith(
                  color: UIConstants.defaultAppColor,
                ),
              ),
              const SizedBox(height: UIConstants.defaultSpacing),
              if (_successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.smallSpacing,
                  ),
                  child: Text(_successMessage, style: UIConstants.successStyle),
                ),
              TextField(
                key: const Key('firstNameField'),
                controller: _firstNameController,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: 'Vorname',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              TextField(
                key: const Key('lastNameField'),
                controller: _lastNameController,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: 'Nachname',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              TextField(
                key: const Key('passNumberField'),
                controller: _passNumberController,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: 'Schützenausweisnummer',
                  errorText: passNumberError,
                ),
                onChanged: (value) {
                  setState(() {
                    validatePassNumber(value);
                  });
                },
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              TextField(
                key: const Key('emailField'),
                controller: _emailController,
                focusNode: _emailFocusNode, // Assign the FocusNode
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: 'E-mail',
                  errorText: _emailFieldTouched
                      ? emailError
                      : null, // Only show error if touched
                ),
                onChanged: (value) {
                  setState(() {
                    if (_emailFieldTouched || value.isNotEmpty) {
                      validateEmail(value);
                    } else {
                      emailError = null; // Clear error if untouched and empty
                    }
                  });
                },
                onTap: () {
                  setState(() {
                    _emailFieldTouched = true; // Mark as touched when focused
                  });
                },
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: UIConstants.defaultInputDecoration.copyWith(
                    labelText: 'Geburtsdatum',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedDate == null
                            ? 'Wählen Sie Ihr Geburtsdatum'
                            : DateFormat(
                                'dd.MM.yyyy',
                                'de_DE',
                              ).format(_selectedDate!),
                        style: UIConstants.bodyStyle.copyWith(
                          color: _selectedDate != null
                              ? UIConstants.calendarSelectedColor
                              : UIConstants.calendarColor,
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              TextField(
                key: const Key('zipCodeField'),
                controller: _zipCodeController,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: 'Postleitzahl',
                  errorText: zipCodeError,
                ),
                onChanged: (value) {
                  setState(() {
                    validateZipCode(value);
                  });
                },
              ),
              const SizedBox(height: UIConstants.smallSpacing),
              Row(
                children: [
                  Checkbox(
                    key: const Key('privacyCheckbox'),
                    value: _privacyAccepted,
                    onChanged: (bool? value) => setState(() {
                      _privacyAccepted = value!;
                    }),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: UIConstants.bodyStyle,
                        children: <TextSpan>[
                          const TextSpan(
                            text:
                                'Ich habe die ', // Directly using the hardcoded text
                          ),
                          TextSpan(
                            text: 'Datenschutzbestimmungen',
                            style: UIConstants.linkStyle.copyWith(
                              color: UIConstants.linkColor,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PrivacyScreen(userData: userData),
                                  ),
                                );
                              },
                          ),
                          const TextSpan(text: ' gelesen und akzeptiere sie.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.defaultSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('submitButton'),
                  onPressed:
                      isFormValid() && !_isLoading ? _registerUser : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIConstants.backgroundColor,
                    padding: UIConstants.buttonPadding,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: UIConstants.sendButtonText,
                        )
                      : Text(
                          'Registrieren',
                          style: UIConstants.bodyStyle.copyWith(
                            color: UIConstants.disabledSubmitButtonText,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
