import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';
import '/services/api/auth_service.dart';
import '/services/core/error_service.dart';
import '/screens/base_screen_layout.dart';
import '/widgets/scaled_text.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({
    required this.email,
    required this.token,
    required this.passNumber,
    required this.authService,
    super.key,
  });

  final String email;
  final String token;
  final String passNumber;
  final AuthService authService;

  @override
  SetPasswordScreenState createState() => SetPasswordScreenState();
}

class SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _passwordError;
  String? _confirmPasswordError;
  String _successMessage = '';
  String _errorMessage = '';
  bool _isLoading = false;

  bool validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordError = Messages.passwordRequired;
      });
      return false;
    }
    if (value.length < 8) {
      setState(() {
        _passwordError = Messages.passwordTooShort;
      });
      return false;
    }
    setState(() {
      _passwordError = null;
    });
    return true;
  }

  bool validateConfirmPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordError = Messages.confirmPasswordRequired;
      });
      return false;
    }
    if (value != _passwordController.text) {
      setState(() {
        _confirmPasswordError = Messages.passwordNoMatch;
      });
      return false;
    }
    setState(() {
      _confirmPasswordError = null;
    });
    return true;
  }

  bool _validateForm() {
    final isPasswordValid = validatePassword(_passwordController.text);
    final isConfirmPasswordValid = validateConfirmPassword(_confirmPasswordController.text);
    return isPasswordValid && isConfirmPasswordValid;
  }

  Future<void> _setPassword() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _successMessage = '';
      _errorMessage = '';
    });

    try {
      final response = await widget.authService.finalizeRegistration(
        email: widget.email,
        password: _passwordController.text,
        token: widget.token,
        passNumber: widget.passNumber,
      );

      if (response['ResultType'] == 1) {
        setState(() {
          _successMessage = Messages.passwordSetSuccess;
          _errorMessage = '';
        });
        
        // Wait for 2 seconds before navigating to login screen
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        setState(() {
          _errorMessage = response['ResultMessage'] ?? Messages.passwordSetError;
          _successMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = Messages.generalError;
        _successMessage = '';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Set Password',
      userData: null,
      isLoggedIn: false,
      onLogout: () {},
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
                child: Text(
                  _successMessage,
                  style: UIStyles.errorStyle.copyWith(
                    color: _successMessage.contains('successfully')
                        ? UIConstants.successColor
                        : UIConstants.errorColor,
                  ),
                ),
              ),
            TextField(
              controller: _passwordController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Password',
                errorText: _passwordError,
              ),
              obscureText: true,
              onChanged: (value) => validatePassword(value),
            ),
            const SizedBox(height: UIConstants.spacingM),
            TextField(
              controller: _confirmPasswordController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Confirm Password',
                errorText: _confirmPasswordError,
              ),
              obscureText: true,
              onChanged: (value) => validateConfirmPassword(value),
            ),
            const SizedBox(height: UIConstants.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _setPassword,
                style: UIStyles.defaultButtonStyle,
                child: SizedBox(
                  height: 36,
                  child: Center(
                    child: _isLoading
                        ? UIConstants.defaultLoadingIndicator
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white),
                              SizedBox(width: UIConstants.spacingS),
                              ScaledText(
                                'Set Password',
                                style: UIStyles.buttonStyle,
                              ),
                            ],
                          ),
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
