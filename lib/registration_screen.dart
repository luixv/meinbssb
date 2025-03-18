import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'localization_service.dart';
import 'logo_widget.dart';
import 'app_menu.dart';
import 'api_service.dart'; 
import 'registration_success_screen.dart';
import 'privacy_page.dart';
import 'package:flutter/gestures.dart';

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
  String _privacyText = "";
  Color _appColor = const Color(0xFF006400);
  String zipCodeError = "";
  String passNumberError = "";
  bool _isLoading = false; 

  String _successMessage = "";

  Map<String, dynamic> userData = {}; 

  @override
  void initState() {
    super.initState();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    setState(() {
      _privacyText = LocalizationService.getString('privacyText');
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
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool validateZipCode(String value) {
    if (value.isEmpty) {
      zipCodeError = "Postleitzahl ist erforderlich.";
      return false;
    }
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      zipCodeError = "Postleitzahl muss 5 Ziffern enthalten.";
      return false;
    }
    zipCodeError = "";
    return true;
  }

  bool validatePassNumber(String value) {
    if (value.isEmpty) {
      passNumberError = "Schützenausweisnummer ist erforderlich.";
      return false;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      passNumberError = "Schützenausweisnummer muss 8 Ziffern enthalten.";
      return false;
    }
    passNumberError = "";
    return true;
  }

  Future<void> _registerUser() async {
  setState(() {
    _isLoading = true;
    _successMessage = ""; // Reset success message
  });

  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a date.")),
    );
    setState(() {
      _isLoading = false;
    });
    return;
  }

  final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

  try {
    final response = await ApiService.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      passNumber: _passNumberController.text,
      email: _emailController.text,
      birthDate: formattedDate,
      zipCode: _zipCodeController.text,
    );

    if (response['ResultType'] == 1) {
      debugPrint("Registration successful: ${response['ResultMessage']}");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationSuccessScreen(
            message: "Registration successful!",
            userData: userData,
          ),
        ),
      );
    } else {
      debugPrint("Registration failed: ${response['ResultMessage']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['ResultMessage'])),
      );
    }
  } catch (e) {
    debugPrint("Error during registration: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
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
          if (_successMessage.isNotEmpty) // Conditionally display success message
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _successMessage,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: "Vorname")),
          TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Nachname")),
          TextField(
            controller: _passNumberController,
            decoration: InputDecoration(labelText: "Schützenausweisnummer", errorText: passNumberError.isNotEmpty ? passNumberError : null),
            onChanged: (value) => validatePassNumber(value),
          ),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: "E-mail")),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: "Geburtsdatum"),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_selectedDate == null ? 'Wählen Sie ein Datum' : DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          TextField(
            controller: _zipCodeController,
            decoration: InputDecoration(labelText: "Postleitzahl", errorText: zipCodeError.isNotEmpty ? zipCodeError : null),
            onChanged: (value) => validateZipCode(value),
          ),
          Row(
            children: [
              Checkbox(
                value: _privacyAccepted,
                onChanged: (bool? value) => setState(() => _privacyAccepted = value!),
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
                        text: LocalizationService.getString('privacyText').split('Datenschutzbestimmungen')[0],
                      ),
                      TextSpan(
                        text: 'Datenschutzbestimmungen',
                        style: const TextStyle(
                          color: Colors.green, // Change link color to green
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
                        text: LocalizationService.getString('privacyText').split('Datenschutzbestimmungen')[1],
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
              onPressed: _privacyAccepted && zipCodeError.isEmpty && passNumberError.isEmpty && !_isLoading
                  ? () {
                      _registerUser();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading ? const CircularProgressIndicator() : const Text("Registrieren"),
            ),
          ),
        ],
      ),
    ),
  );
}

}