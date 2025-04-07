import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'logo_widget.dart';
import 'app_menu.dart';
import 'package:meinbssb/services/api_service.dart';
import 'registration_success_screen.dart';
import 'privacy_page.dart';
import 'package:flutter/gestures.dart';
import 'package:meinbssb/services/email_service.dart';

class RegistrationScreen extends StatefulWidget {
  final ApiService apiService;
  final EmailService emailService;

  const RegistrationScreen({
    required this.apiService,
    required this.emailService,
    super.key,
  });

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
  String _successMessage = "";
  Map<String, dynamic> userData = {};

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
    _loadLocalization();
    zipCodeError = null;
    passNumberError = null;
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
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
            ).colorScheme.copyWith(primary: UIConstants.lightGreen),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: UIConstants.lightGreen,
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
    if (value.isEmpty) {
      return false;
    }
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  bool validateZipCode(String value) {
    if (value.isEmpty) {
      zipCodeError = "Postleitzahl ist erforderlich.";
    } else if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      zipCodeError = "Postleitzahl muss 5 Ziffern enthalten.";
    } else {
      zipCodeError = null;
    }
    return zipCodeError == null;
  }

  bool validatePassNumber(String value) {
    if (value.isEmpty) {
      passNumberError = "Schützenausweisnummer ist erforderlich.";
    } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      passNumberError = "Schützenausweisnummer muss 8 Ziffern enthalten.";
    } else {
      passNumberError = null;
    }
    return passNumberError == null;
  }

  bool isFormValid() {
    final isZipValid =
        _zipCodeController.text.isNotEmpty
            ? validateZipCode(_zipCodeController.text)
            : true;
    final isPassValid =
        _passNumberController.text.isNotEmpty
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
      _successMessage = "";
    });

    await Future.delayed(UIConstants.loadingDelay);

    if (_selectedDate == null || !_selectedDate!.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Bitte wählen Sie ein gültiges Geburtsdatum in der Vergangenheit.",
              style: UIConstants.bodyStyle,
            ),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      final response = await widget.apiService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        passNumber: _passNumberController.text,
        email: _emailController.text,
        birthDate: formattedDate,
        zipCode: _zipCodeController.text,
      );

      if (response['ResultType'] == 1) {
        debugPrint("Registration successful: ${response['ResultMessage']}");
        bool emailSent = false;

        try {
          await _sendRegistrationEmail();
          emailSent = true;
        } catch (e) {
          debugPrint("Email sending error: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Registrierung fehlgeschlagen! Bitte versuchen Sie es später noch einmal.",
                  style: UIConstants.bodyStyle,
                ),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RegistrationSuccessScreen(
                    message:
                        emailSent
                            ? "Registrierung erfolgreich!"
                            : "Registrierung nicht erfolgreich! versuchen Sie es später erneut.",
                    userData: userData,
                  ),
            ),
          );
        }
      } else {
        debugPrint("Registration failed: ${response['ResultMessage']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['ResultMessage'] ?? "Registrierung fehlgeschlagen",
                style: UIConstants.bodyStyle,
              ),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error during registration: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Fehler bei der Registrierung. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es später erneut.",
              style: UIConstants.bodyStyle,
            ),
            duration: UIConstants.snackBarDuration,
          ),
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
      String from = LocalizationService.getString('From');
      String subject = LocalizationService.getString('Subject');
      String registrationContent = LocalizationService.getString(
        'registrationContent',
      );

      final emailResponse = await widget.emailService.sendEmail(
        from: from,
        recipient: _emailController.text,
        subject: subject,
        body: registrationContent,
      );

      if (emailResponse['ResultType'] != 1) {
        throw Exception(emailResponse['ResultMessage']);
      }
    } catch (e) {
      debugPrint("Error sending email: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrierung', style: UIConstants.titleStyle),
        automaticallyImplyLeading: false,
        actions: [
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
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              "Hier Registrieren",
              style: UIConstants.headerStyle.copyWith(
                color: UIConstants.lightGreen,
              ),
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: UIConstants.smallSpacing,
                ),
                child: Text(_successMessage, style: UIConstants.successStyle),
              ),
            TextField(
              key: const Key('firstNameField'),
              controller: _firstNameController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: "Vorname",
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: UIConstants.smallSpacing),
            TextField(
              key: const Key('lastNameField'),
              controller: _lastNameController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: "Nachname",
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: UIConstants.smallSpacing),
            TextField(
              key: const Key('passNumberField'),
              controller: _passNumberController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: "Schützenausweisnummer",
                errorText: passNumberError,
              ),
              onChanged: (value) {
                setState(() {
                  passNumberError =
                      validatePassNumber(value)
                          ? null
                          : "Schützenausweisnummer muss 8 Ziffern enthalten.";
                });
              },
            ),
            SizedBox(height: UIConstants.smallSpacing),
            TextField(
              key: const Key('emailField'),
              controller: _emailController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: "E-mail",
                errorText: emailError,
              ),
              onChanged: (_) {
                setState(() {
                  emailError =
                      validateEmail(_emailController.text)
                          ? null
                          : "Bitte geben Sie eine gültige E-Mail Adresse ein.";
                });
              },
            ),
            SizedBox(height: UIConstants.smallSpacing),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: "Geburtsdatum",
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
                        color:
                            _selectedDate != null
                                ? UIConstants.lightGreen
                                : UIConstants.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: UIConstants.smallSpacing),
            TextField(
              key: const Key('zipCodeField'),
              controller: _zipCodeController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: "Postleitzahl",
                errorText: zipCodeError,
              ),
              onChanged: (value) {
                setState(() {
                  zipCodeError =
                      validateZipCode(value)
                          ? null
                          : "Postleitzahl muss 5 Ziffern enthalten.";
                });
              },
            ),
            SizedBox(height: UIConstants.smallSpacing),
            Row(
              children: [
                Checkbox(
                  value: _privacyAccepted,
                  onChanged:
                      (bool? value) => setState(() {
                        _privacyAccepted = value!;
                      }),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: UIConstants.bodyStyle,
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              LocalizationService.getString(
                                'privacyText',
                              ).split('Datenschutzbestimmungen')[0],
                        ),
                        TextSpan(
                          text: 'Datenschutzbestimmungen',
                          style: UIConstants.linkStyle.copyWith(
                            color: UIConstants.lightGreen,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              PrivacyPage(userData: userData),
                                    ),
                                  );
                                },
                        ),
                        TextSpan(
                          text:
                              LocalizationService.getString(
                                'privacyText',
                              ).split('Datenschutzbestimmungen')[1],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid() && !_isLoading ? _registerUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.lightGreen,
                  padding: UIConstants.buttonPadding,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(
                          color: UIConstants.white,
                          strokeWidth: 2.0,
                        )
                        : Text(
                          "Registrieren",
                          style: UIConstants.bodyStyle.copyWith(
                            color: UIConstants.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
