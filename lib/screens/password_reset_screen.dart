// Project: Mein BSSB
// Filename: password_reset_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '/services/error_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({required this.authService, super.key});
  final AuthService authService;

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
      appBar: AppBar(title: const Text('Passwort zurücksetzen')),
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Passwort zurücksetzen',
              style: UIConstants.headerStyle.copyWith(
                color: UIConstants.lightGreen,
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
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.lightGreen,
                  padding: UIConstants.buttonPadding,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(
                          color: UIConstants.white,
                          strokeWidth: 2.0,
                        )
                        : const Text(
                          'Passwort zurücksetzen',
                          style: UIConstants.bodyStyle,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
