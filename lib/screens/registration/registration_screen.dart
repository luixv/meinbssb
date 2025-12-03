import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/screens/datenschutz_screen.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/registration/registration_success_screen.dart';
import 'package:meinbssb/screens/registration/registration_fail_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.apiService, super.key});
  final ApiService apiService;

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _privacyAccepted = false;
  String? passNumberError;
  String? emailError;
  final String _successMessage = '';
  UserData? userData;
  bool _formSubmitted = false; // Track if form was submitted
  String? _existingAccountMessage; // Message to show if account already exists

  bool _isRegistering = false; // Loading state for registration

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get passNumberController => _passNumberController;
  TextEditingController get emailController => _emailController;
  bool get privacyAccepted => _privacyAccepted;

  @override
  void initState() {
    super.initState();
    passNumberError = null;
    emailError = null;
    _formSubmitted = false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool validateEmail(String value) {
    if (value.isEmpty) {
      if (_formSubmitted) {
        emailError = Messages.emailRequired;
      }
      return false;
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      if (_formSubmitted) {
        emailError = Messages.invalidEmail;
      }
      return false;
    }
    emailError = null;
    return true;
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

  Future<void> _checkExistingAccount(String passNumber) async {
    try {
      final loginMail = await widget.apiService.findeLoginMail(passNumber);
      if (loginMail.isNotEmpty) {
        setState(() {
          _existingAccountMessage =
              'Sie haben bereits einen MeinBSSB Account.\nBitte verwenden Sie ihre bekannten Zugangsdaten.';
        });
      } else {
        setState(() {
          _existingAccountMessage = null;
        });
      }
    } catch (e) {
      // If there's an error checking, just clear the message
      setState(() {
        _existingAccountMessage = null;
      });
    }
  }

  bool isFormValid() {
    final isPassValid =
        _passNumberController.text.isNotEmpty
            ? validatePassNumber(_passNumberController.text)
            : true;
    final isEmailValid = validateEmail(_emailController.text);

    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        isEmailValid &&
        isPassValid &&
        _privacyAccepted;
  }

  bool _validateForm() {
    return isFormValid();
  }

  Future<void> _register() async {
    setState(() {
      _formSubmitted = true;
      _isRegistering = true;
    });
    // Check for offline before proceeding
    final isOffline = !(await widget.apiService.hasInternet());
    if (isOffline) {
      setState(() {
        _isRegistering = false;
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => const RegistrationFailScreen(
                message: Messages.registrationOffline,
                userData: null,
              ),
        ),
      );
      return;
    }

    if (!_validateForm()) {
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    try {
      // First find PersonID
      final personIdInt = await widget.apiService.authService
          .findePersonIDSimple(
            _firstNameController.text,
            _lastNameController.text,
            _passNumberController.text,
          );

      if (personIdInt == 0) {
        setState(() {
          _isRegistering = false;
        });
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => const RegistrationFailScreen(
                  message: Messages.noPersonIdFound,
                  userData: null,
                ),
          ),
        );
        return;
      }

      // Check for existing MeinBSSB account
      await _checkExistingAccount(_passNumberController.text);
      if (_existingAccountMessage != null) {
        setState(() {
          _isRegistering = false;
        });
        return;
      }

      // Check if user already exists in PostgreSQL
      final existingUser = await widget.apiService.authService.postgrestService
          .getUserByPassNumber(_passNumberController.text);
      if (existingUser != null) {
        // Check if user exists with this email
        final userWithEmail = await widget
            .apiService
            .authService
            .postgrestService
            .getUserByEmail(_emailController.text);

        // If either the pass number or email is verified, prevent registration
        if ((existingUser['is_verified'] == true) ||
            (userWithEmail != null && userWithEmail['is_verified'] == true)) {
          setState(() {
            _isRegistering = false;
          });
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => const RegistrationFailScreen(
                    message: Messages.registrationDataAlreadyUsed,
                    userData: null,
                  ),
            ),
          );
          return;
        }

        // If not verified, check if registration is older than 24 hours
        final createdAt = DateTime.parse(existingUser['created_at']);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inHours <= 24) {
          setState(() {
            _isRegistering = false;
          });
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => const RegistrationFailScreen(
                    message: Messages.registrationDataAlreadyExists,
                    userData: null,
                  ),
            ),
          );
          return;
        }
      }

      // Complete the registration
      final result = await widget.apiService.authService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        passNumber: _passNumberController.text,
        email: _emailController.text,
        personId: personIdInt.toString(),
      );

      setState(() {
        _isRegistering = false;
      });

      if (!mounted) return;

      // Check if registration was successful
      if (result['ResultType'] == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => const RegistrationSuccessScreen(
                  message: Messages.registrationSuccess,
                  userData: null,
                ),
          ),
        );
      } else {
        // Registration failed, show error message
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => RegistrationFailScreen(
                  message: result['ResultMessage'] ?? Messages.generalError,
                  userData: null,
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => const RegistrationFailScreen(
                message: Messages.generalError,
                userData: null,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return BaseScreenLayout(
      title: 'Registrierung',
      userData: null,
      isLoggedIn: false,
      onLogout: () {},
      body: Semantics(
        label:
            'Registrierungsformular. Bitte geben Sie Ihre persönlichen Daten ein, akzeptieren Sie die Datenschutzbestimmungen und drücken Sie auf Registrieren, um sich zu registrieren.',
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: UIConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LogoWidget(),
                  const SizedBox(height: UIConstants.spacingS),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: UIConstants.spacingM,
                      ),
                      child: Semantics(
                        label: 'Erfolgsmeldung: $_successMessage',
                        child: Text(
                          _successMessage,
                          style: UIStyles.errorStyle.copyWith(
                            color: UIConstants.errorColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  Semantics(
                  label: 'Vorname Eingabefeld',
                  child: TextField(
                    controller: _firstNameController,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: Messages.firstNameLabel,
                      labelStyle: UIStyles.formLabelStyle.copyWith(
                        fontSize:
                            UIStyles.formLabelStyle.fontSize != null
                                ? UIStyles.formLabelStyle.fontSize! *
                                    fontSizeProvider.scaleFactor
                                : null,
                      ),
                    ),
                    style: UIStyles.formValueStyle.copyWith(
                      fontSize:
                          UIStyles.formValueStyle.fontSize != null
                              ? UIStyles.formValueStyle.fontSize! *
                                  fontSizeProvider.scaleFactor
                              : null,
                    ),
                  ),
                ),
                  const SizedBox(height: UIConstants.spacingS),
                  Semantics(
                  label: 'Nachname Eingabefeld',
                  child: TextField(
                    controller: _lastNameController,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: Messages.lastNameLabel,
                      labelStyle: UIStyles.formLabelStyle.copyWith(
                        fontSize:
                            UIStyles.formLabelStyle.fontSize != null
                                ? UIStyles.formLabelStyle.fontSize! *
                                    fontSizeProvider.scaleFactor
                                : null,
                      ),
                    ),
                    style: UIStyles.formValueStyle.copyWith(
                      fontSize:
                          UIStyles.formValueStyle.fontSize != null
                              ? UIStyles.formValueStyle.fontSize! *
                                  fontSizeProvider.scaleFactor
                              : null,
                    ),
                  ),
                ),
                  const SizedBox(height: UIConstants.spacingS),
                  Semantics(
                  label: 'E-Mail Eingabefeld',
                  child: TextField(
                    controller: _emailController,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: 'E-Mail',
                      errorText: emailError,
                      labelStyle: UIStyles.formLabelStyle.copyWith(
                        fontSize:
                            UIStyles.formLabelStyle.fontSize != null
                                ? UIStyles.formLabelStyle.fontSize! *
                                    fontSizeProvider.scaleFactor
                                : null,
                      ),
                    ),
                    style: UIStyles.formValueStyle.copyWith(
                      fontSize:
                          UIStyles.formValueStyle.fontSize != null
                              ? UIStyles.formValueStyle.fontSize! *
                                  fontSizeProvider.scaleFactor
                              : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {
                        validateEmail(value);
                      });
                    },
                  ),
                ),
                  const SizedBox(height: UIConstants.spacingS),
                  Semantics(
                  label: 'Schützenausweisnummer Eingabefeld',
                  child: TextField(
                    controller: _passNumberController,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: 'Schützenausweisnummer',
                      errorText: passNumberError,
                      labelStyle: UIStyles.formLabelStyle.copyWith(
                        fontSize:
                            UIStyles.formLabelStyle.fontSize != null
                                ? UIStyles.formLabelStyle.fontSize! *
                                    fontSizeProvider.scaleFactor
                                : null,
                      ),
                    ),
                    style: UIStyles.formValueStyle.copyWith(
                      fontSize:
                          UIStyles.formValueStyle.fontSize != null
                              ? UIStyles.formValueStyle.fontSize! *
                                  fontSizeProvider.scaleFactor
                              : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        validatePassNumber(value);
                      });
                    },
                  ),
                ),
                  if (passNumberError != null)
                    Semantics(
                      label: 'Fehlermeldung: $passNumberError',
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          passNumberError!,
                          style: UIStyles.errorStyle,
                        ),
                      ),
                    ),
                  if (_existingAccountMessage != null)
                    Semantics(
                      label: 'Warnung: $_existingAccountMessage',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: UIConstants.errorColor.withOpacity(0.1),
                            border: Border.all(
                              color: UIConstants.errorColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: UIConstants.errorColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _existingAccountMessage!,
                                  style: UIStyles.bodyStyle.copyWith(
                                    color: UIConstants.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: UIConstants.spacingM),
                  Semantics(
                    label: 'Datenschutzbestimmungen akzeptieren Checkbox',
                    child: _buildPrivacyCheckbox(fontSizeProvider),
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  Semantics(
                    label: 'Registrieren Button',
                    child: _buildRegisterButton(fontSizeProvider),
                  ),
                ],
              ),
            ),
            if (_isRegistering)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // fontSizeProvider now initialized in build method

  Widget _buildPrivacyCheckbox(FontSizeProvider fontSizeProvider) {
    return Row(
      children: [
        Checkbox(
          key: const Key('privacyCheckbox'),
          activeColor: UIConstants.defaultAppColor,
          value: _privacyAccepted,
          onChanged:
              (bool? value) => setState(() {
                _privacyAccepted = value!;
              }),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: UIStyles.bodyStyle.copyWith(
                fontSize:
                    UIStyles.bodyStyle.fontSize != null
                        ? UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor
                        : null,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Ich habe die '),
                TextSpan(
                  text: 'Datenschutzbestimmungen',
                  style: UIStyles.linkStyle.copyWith(
                    color: UIConstants.linkColor,
                    decoration: TextDecoration.underline,
                    fontSize:
                        UIStyles.linkStyle.fontSize != null
                            ? UIStyles.linkStyle.fontSize! *
                                fontSizeProvider.scaleFactor
                            : null,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DatenschutzScreen(
                                    userData: userData,
                                    isLoggedIn: false,
                                    onLogout: () {},
                                  ),
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

  Widget _buildRegisterButton(FontSizeProvider fontSizeProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('registerButton'),
        onPressed: _validateForm() ? _register : null,
        style: UIStyles.defaultButtonStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.app_registration, color: Colors.white),
            const SizedBox(width: UIConstants.spacingS),
            ScaledText(
              'Registrieren',
              style: UIStyles.buttonStyle.copyWith(
                fontSize:
                    UIStyles.buttonStyle.fontSize != null
                        ? UIStyles.buttonStyle.fontSize! *
                            fontSizeProvider.scaleFactor
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
