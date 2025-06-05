// Project: Mein BSSB
// Filename: password_reset_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '../services/core/error_service.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart'; // Import the ConnectivityIcon

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    required this.authService,
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final AuthService authService;
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passNumberController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _passNumberController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await widget.authService.resetPassword(
        _passNumberController.text,
      );

      if (response['ResultType'] == 1) {
        setState(() {
          _successMessage = response['ResultMessage'];
        });
      } else {
        setState(() {
          _errorMessage = response['ResultMessage'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorService.handleNetworkError(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundGreen,
        title: const Text(
          'Passworrt zurücksetzen',
          style: UIConstants.titleStyle,
        ),
        actions: [
          // --- Added ConnectivityIcon here ---
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(), // The ConnectivityIcon
          ),
          // --- End ConnectivityIcon addition ---
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Passwort zurücksetzen',
              key: const Key('passwordResetTitle'),
              style: UIConstants.headerStyle.copyWith(
                color: UIConstants.defaultAppColor,
              ),
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: UIConstants.errorStyle),
            if (_successMessage.isNotEmpty)
              Text(_successMessage, style: UIConstants.successStyle),
            TextField(
              controller: _passNumberController,
              decoration: UIConstants.defaultInputDecoration.copyWith(
                labelText: 'Schützenausweisnummer',
              ),
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('forgotPasswordButton'),
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.acceptButton,
                  padding: UIConstants.buttonPadding,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          UIConstants.white,
                        ),
                      )
                    : const Text(
                        'Passwort zurücksetzen',
                        style: TextStyle(
                          fontSize: UIConstants.bodyFontSize,
                          color: UIConstants.sendButton,
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
