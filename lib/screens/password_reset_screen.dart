import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';  
import 'logo_widget.dart';
import 'app_menu.dart'; 
import 'package:meinbssb/services/localization_service.dart'; // moved
import 'password_reset_success_screen.dart'; 

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passNumberController = TextEditingController();
  String _passNumberError = "";
  bool _isPassNumberValid = false; // Initialize to false
  bool _hasInteracted = false;
  bool _isLoading = false;
  Color _appColor = const Color(0xFF006400);

  @override
  void initState() {
    super.initState();
    _loadLocalization();
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

  bool _validatePassNumber(String value) {
    if (value.isEmpty) {
      _passNumberError = "Passnummer ist erforderlich.";
      return false;
    }
    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
      _passNumberError = "Passnummer muss 8 Ziffern enthalten.";
      return false;
    }
    _passNumberError = "";
    return true;
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _passNumberError = "";
    });

    if (!_isPassNumberValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService().resetPassword(_passNumberController.text);
      if (response['ResultType'] == 1) {
        try {
          final userData = await ApiService().fetchPassdatenWithString(_passNumberController.text);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PasswordResetSuccessScreen(userData: userData),
              ),
            );
          }
        } catch (e) {
          setState(() {
            _passNumberError = "Ein Fehler ist aufgetreten: $e";
          });
        }
      } else {
        setState(() {
          _passNumberError = response['ResultMessage'];
        });
      }
    } catch (e) {
      setState(() {
        _passNumberError = "Ein Fehler ist aufgetreten: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwort zurücksetzen'),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              const SizedBox(height: 20),
              Text(
                "Passwort zurücksetzen",
                style: TextStyle(
                  color: _appColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Passnummer",
                  errorText: _hasInteracted && _passNumberError.isNotEmpty ? _passNumberError : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _hasInteracted = true;
                    _isPassNumberValid = _validatePassNumber(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPassNumberValid && !_isLoading ? _resetPassword : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text("Passwort zurücksetzen"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}