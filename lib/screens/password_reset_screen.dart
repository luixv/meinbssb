// Project: Mein BSSB
// Filename: password_reset_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'logo_widget.dart';
import 'app_menu.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'password_reset_success_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  final ApiService apiService;
  const PasswordResetScreen({required this.apiService, super.key});

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passNumberController = TextEditingController();
  String _passNumberError = "";
  bool _isPassNumberValid = false;
  bool _hasInteracted = false;
  bool _isLoading = false;
  Color _appColor = UIConstants.defaultAppColor;

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
      final response = await widget.apiService.resetPassword(
        _passNumberController.text,
      );

      if (response['ResultType'] == 1) {
        try {
          final userData = await widget.apiService.fetchPassdaten(
            int.parse(_passNumberController.text),
          );

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PasswordResetSuccessScreen(
                      userData: userData,
                      // Temporarily removed apiService parameter
                    ),
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
        title: Text('Passwort zurücksetzen', style: UIConstants.titleStyle),
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
        child: Padding(
          padding: UIConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LogoWidget(),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                "Passwort zurücksetzen",
                style: UIConstants.headerStyle.copyWith(color: _appColor),
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              TextField(
                controller: _passNumberController,
                keyboardType: TextInputType.number,
                decoration: UIConstants.defaultInputDecoration.copyWith(
                  labelText: "Passnummer",
                  errorText:
                      _hasInteracted && _passNumberError.isNotEmpty
                          ? _passNumberError
                          : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _hasInteracted = true;
                    _isPassNumberValid = _validatePassNumber(value);
                  });
                },
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isPassNumberValid && !_isLoading ? _resetPassword : null,
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
                            "Passwort zurücksetzen",
                            style: UIConstants.bodyStyle.copyWith(
                              color: UIConstants.white,
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
