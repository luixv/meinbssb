// Project: Mein BSSB
// Filename: registration_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/screens/privacy_screen.dart';
import 'package:meinbssb/screens/registration_result_screen.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/error_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

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
  String _successMessage = '';
  UserData? userData;
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: UIConstants.defaultAppColor,
                  onPrimary: UIConstants.whiteColor,
                  surface: UIConstants.calendarBackgroundColor,
                  onSurface: UIConstants.textColor,
                ),
            textButtonTheme: const TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  UIConstants.cancelButtonBackground,
                ),
                foregroundColor: WidgetStatePropertyAll(UIConstants.whiteColor),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                    vertical: UIConstants.spacingSM,
                  ),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(Size(120, 48)),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: UIConstants.calendarBackgroundColor,
              backgroundColor: UIConstants.calendarBackgroundColor,
              headerForegroundColor: UIConstants.textColor,
              dayStyle: TextStyle(color: UIConstants.textColor),
              yearStyle: TextStyle(color: UIConstants.textColor),
              weekdayStyle: TextStyle(color: UIConstants.textColor),
              confirmButtonStyle: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(UIConstants.primaryColor),
                foregroundColor: WidgetStatePropertyAll(UIConstants.whiteColor),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                    vertical: UIConstants.spacingSM,
                  ),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(Size(120, 48)),
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
      emailError = null;
      return true;
    }
    if (value.isEmpty) {
      emailError = Messages.emailRequired;
      return false;
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      emailError = Messages.invalidEmail;
      return false;
    }
    emailError = null;
    return true;
  }

  bool validateZipCode(String value) {
    if (value.isEmpty) {
      zipCodeError = Messages.zipCodeRequired;
    } else if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      zipCodeError = Messages.invalidZipCode;
    } else {
      zipCodeError = null;
    }
    return zipCodeError == null;
  }

  bool validatePassNumber(String value) {
    if (value.isEmpty) {
      passNumberError = Messages.passNumberRequired;
    } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      passNumberError = Messages.invalidPassNumber;
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

  bool _validateForm() {
    return isFormValid();
  }

  Future<void> _register() async {
    // Check for offline before proceeding
    final networkService = Provider.of<NetworkService>(context, listen: false);
    final isOffline = !(await networkService.hasInternet());
    if (isOffline) {
      setState(() {
        _successMessage =
            'Registrierung ist offline nicht verfügbar. Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind.';
      });
      return;
    }

    if (!_validateForm()) return;

    try {
      final personId = await widget.authService
          .getPersonIDByPassnummer(_passNumberController.text);

      if (personId == '0') {
        setState(() {
          _successMessage = Messages.noPersonIdFound;
        });
        return;
      }

      // Generate a verification token (you might want to move this to the server side)
      final verificationToken =
          DateTime.now().millisecondsSinceEpoch.toString();

      // Get the verification base URL from config
      final baseUrl = await widget.emailService.getVerificationBaseUrl();
      if (baseUrl == null) {
        setState(() {
          _successMessage = Messages.configError;
        });
        return;
      }

      // Create verification link
      final verificationLink =
          '$baseUrl?email=${_emailController.text}&token=$verificationToken';

      // Get email template
      final fromEmail = await widget.emailService.getFromEmail();
      final subject = await widget.emailService.getRegistrationSubject();
      final emailContent = await widget.emailService.getRegistrationContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        setState(() {
          _successMessage = Messages.emailConfigError;
        });
        return;
      }

      // Replace placeholders in the email content
      final emailBody = emailContent
          .replaceAll('{firstName}', _firstNameController.text)
          .replaceAll('{verificationLink}', verificationLink);

      // Send the verification email
      final emailResponse = await widget.emailService.sendEmail(
        from: fromEmail,
        recipient: _emailController.text,
        subject: subject,
        body: emailBody,
      );

      if (emailResponse['ResultType'] == 1) {
        // Store the registration data temporarily (you might want to move this to the server)
        await widget.authService.register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          passNumber: _passNumberController.text,
          email: _emailController.text,
          birthDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
          zipCode: _zipCodeController.text,
        );

        setState(() {
          _successMessage = Messages.emailSentSuccess;
        });
      } else {
        setState(() {
          _successMessage = ErrorService.handleValidationError(
            'Registration',
            emailResponse['ResultMessage'] ?? Messages.generalError,
          );
        });
      }
    } catch (e) {
      setState(() {
        _successMessage = ErrorService.handleValidationError(
          'Registration',
          Messages.generalError,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Registrierung',
      userData: null,
      isLoggedIn: false,
      onLogout: () {},
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
                child: Text(
                  _successMessage,
                  style: UIStyles.errorStyle.copyWith(
                    color: UIConstants.errorColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            TextField(
              controller: _firstNameController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: UIConstants.firstNameLabel,
              ),
              style: UIStyles.formValueStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            TextField(
              controller: _lastNameController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: UIConstants.lastNameLabel,
              ),
              style: UIStyles.formValueStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            TextField(
              controller: _emailController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'E-Mail',
                errorText: emailError,
              ),
              style: UIStyles.formValueStyle,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocusNode,
              onChanged: (value) {
                setState(() {
                  validateEmail(value);
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingS),
            TextField(
              controller: _passNumberController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Schützenausweisnummer',
                errorText: passNumberError,
              ),
              style: UIStyles.formValueStyle,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  validatePassNumber(value);
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingS),
            TextField(
              controller: _zipCodeController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Postleitzahl',
                errorText: zipCodeError,
              ),
              style: UIStyles.formValueStyle,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  validateZipCode(value);
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingS),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: UIStyles.formInputDecoration.copyWith(
                  labelText: 'Geburtsdatum',
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _selectedDate == null
                          ? 'Wählen Sie Ihr Geburtsdatum'
                          : DateFormat('dd.MM.yyyy', 'de_DE')
                              .format(_selectedDate!),
                      style: UIStyles.formValueStyle.copyWith(
                        color: _selectedDate != null
                            ? UIConstants.textColor
                            : UIConstants.greySubtitleTextColor,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            _buildPrivacyCheckbox(),
            const SizedBox(height: UIConstants.spacingM),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCheckbox() {
    return Row(
      children: [
        Checkbox(
          key: const Key('privacyCheckbox'),
          activeColor: UIConstants.defaultAppColor,
          value: _privacyAccepted,
          onChanged: (bool? value) => setState(() {
            _privacyAccepted = value!;
          }),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: UIStyles.bodyStyle,
              children: <TextSpan>[
                const TextSpan(text: 'Ich habe die '),
                TextSpan(
                  text: 'Datenschutzbestimmungen',
                  style: UIStyles.linkStyle.copyWith(
                    color: UIConstants.linkColor,
                    decoration: TextDecoration.underline,
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
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('registerButton'),
        onPressed: _validateForm() ? _register : null,
        style: UIStyles.defaultButtonStyle,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.app_registration, color: Colors.white),
            SizedBox(width: UIConstants.spacingS),
            ScaledText(
              'Registrieren',
              style: UIStyles.buttonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
