// Project: Mein BSSB
// Filename: password_reset_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '/services/core/error_service.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    required this.authService,
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final AuthService authService;
  final UserData? userData;
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
    return BaseScreenLayout(
      title: UIConstants.passwordResetTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            ScaledText(
              UIConstants.passwordResetTitle,
              key: const Key('passwordResetTitle'),
              style: UIStyles.headerStyle.copyWith(
                color: UIConstants.defaultAppColor,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            if (_errorMessage.isNotEmpty)
              ScaledText(_errorMessage, style: UIStyles.errorStyle),
            if (_successMessage.isNotEmpty)
              ScaledText(_successMessage, style: UIStyles.successStyle),
            TextField(
              controller: _passNumberController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: UIConstants.passNumberLabel,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('forgotPasswordButton'),
                onPressed: _isLoading ? null : _resetPassword,
                style: UIStyles.defaultButtonStyle,
                child: _isLoading
                    ? UIConstants.defaultLoadingIndicator
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_reset, color: Colors.white),
                          SizedBox(width: UIConstants.spacingS),
                          ScaledText(
                            UIConstants.resetPasswordButtonLabel,
                            style: UIStyles.buttonStyle,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
