import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meinbssb/services/localization_service.dart'; 
import 'logo_widget.dart';
import 'app_menu.dart';
import 'package:meinbssb/services/api_service.dart';
import 'registration_success_screen.dart';
import 'privacy_page.dart';
import 'package:flutter/gestures.dart';
import 'package:meinbssb/services/email_service.dart'; // Import EmailService


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

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
  Color _appColor = const Color(0xFF006400);
  String? zipCodeError;
  String? passNumberError;
  String? emailError;
  bool _isLoading = false; 
  String _successMessage = "";
  Map<String, dynamic> userData = {};

  // Getter methods for testing
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
    setState(() {
      final colorString = LocalizationService.getString('appColor');
      if (colorString.isNotEmpty) {
        _appColor = Color(int.parse(colorString));
      }
    });
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
              primary: _appColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _appColor,
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
      return false; // Email is required
    }
    // Basic email regex
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
        _zipCodeController.text.isNotEmpty ? validateZipCode(_zipCodeController.text) : true;
    final isPassValid =
        _passNumberController.text.isNotEmpty ? validatePassNumber(_passNumberController.text) : true;
    final isDateValid = _selectedDate != null && _selectedDate!.isBefore(DateTime.now());
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

  await Future.delayed(const Duration(milliseconds: 100)); // wait for the DB creation.


  if (_selectedDate == null || !_selectedDate!.isBefore(DateTime.now())) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid past date.")),
      );
    }

    setState(() {
      _isLoading = false;
    });
    return;
  }

  final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

  try {
    final response = await ApiService().register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      passNumber: _passNumberController.text,
      email: _emailController.text,
      birthDate: formattedDate,
      zipCode: _zipCodeController.text,
    );

    if (response['ResultType'] == 1) {
      debugPrint("Registration successful: ${response['ResultMessage']}");
      await _sendRegistrationEmail(); // Call the new method to send email

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationSuccessScreen(
              message: "Registration successful!",
              userData: userData,
            ),
          ),
        );
      }
    } else {
      debugPrint("Registration failed: ${response['ResultMessage']}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['ResultMessage'])),
        );
      }
    }
  } catch (e) {
    debugPrint("Error during registration: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

Future<void> _sendRegistrationEmail() async {
  // Extract parameters from the strings.json
  String from = LocalizationService.getString('From'); // From address
  String subject = LocalizationService.getString('Subject');
  String registrationContent = LocalizationService.getString('registrationContent');

  final emailResponse = await EmailService().sendEmail(
    from: from,
    recipient: _emailController.text, // Change 'to' to 'recipient'
    subject: subject,
    body: registrationContent,
  );

  if (emailResponse['ResultType'] == 1) {
    debugPrint("Email sent successfully: ${emailResponse['ResultMessage']}");
  } else {
    debugPrint("Email sending failed: ${emailResponse['ResultMessage']}");
  }
}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrierung'),
        automaticallyImplyLeading: false,
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            showSingleMenuItem: true,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: 20),
            Text(
              "Hier Registrieren",
              style: TextStyle(
                color: _appColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            TextField(
              key: Key('firstNameField'),
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "Vorname"),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: Key('lastNameField'),
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "Nachname"),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              key: Key('passNumberField'),
              controller: _passNumberController,
              decoration: InputDecoration(
                labelText: "Schützenausweisnummer",
                errorText: passNumberError,
              ),
              onChanged: (value) {
                setState(() {
                  passNumberError =
                      validatePassNumber(value) ? null : "Schützenausweisnummer muss 8 Ziffern enthalten.";
                });
              },
            ),
            TextField(
              key: Key('emailField'),
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "E-mail",
                errorText: emailError,
              ),
              onChanged: (_) {
                setState(() {
                  emailError = validateEmail(_emailController.text)
                      ? null
                      : "Bitte geben Sie eine gültige E-Mail Adresse ein.";
                });
              },
            ),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: "Geburtsdatum"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _selectedDate == null
                          ? 'Wählen Sie Ihr Geburtsdatum'
                          : DateFormat('dd.MM.yyyy', 'de_DE').format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate != null ? _appColor : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            TextField(
              key: Key('zipCodeField'),
              controller: _zipCodeController,
              decoration: InputDecoration(
                labelText: "Postleitzahl",
                errorText: zipCodeError,
              ),
              onChanged: (value) {
                setState(() {
                  zipCodeError = validateZipCode(value) ? null : "Postleitzahl muss 5 Ziffern enthalten.";
                });
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: _privacyAccepted,
                  onChanged: (bool? value) => setState(() {
                    _privacyAccepted = value!;
                  }),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: LocalizationService.getString('privacyText')
                              .split('Datenschutzbestimmungen')[0],
                        ),
                        TextSpan(
                          text: 'Datenschutzbestimmungen',
                          style: const TextStyle(
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPage(userData: userData),
                                ),
                              );
                            },
                        ),
                        TextSpan(
                          text: LocalizationService.getString('privacyText')
                              .split('Datenschutzbestimmungen')[1],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid() && !_isLoading ? _registerUser : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Registrieren"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}