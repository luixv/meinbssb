import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key, required this.onLoginSuccess});
  final Function(UserData) onLoginSuccess;

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;

      if (response['ResultType'] == 1) {
        final personId = response['PersonID'];
        final webloginId = response['WebLoginID'];
        final passdaten = await apiService.fetchPassdaten(personId);
        if (!mounted) return;

        if (passdaten != null) {
          final userData = passdaten.copyWith(webLoginId: webloginId);
          Navigator.of(context).pop();
          widget.onLoginSuccess(userData);
        } else {
          setState(() => _errorMessage = 'Fehler beim Laden der Passdaten.');
        }
      } else {
        setState(
          () =>
              _errorMessage =
                  response['ResultMessage'] ?? 'Login fehlgeschlagen.',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Fehler: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIConstants.backgroundColor,
      title: const Center(
        child: ScaledText(
          'Login erforderlich',
          style: UIStyles.dialogTitleStyle,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Padding(
            padding: UIConstants.dialogPadding.copyWith(
              bottom: UIConstants.spacingS,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: UIConstants.spacingS,
                    ),
                    child: ScaledText(
                      _errorMessage,
                      style: UIStyles.errorStyle,
                    ),
                  ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'E-Mail',
                  ),
                  enabled: !_isLoading,
                  style: UIStyles.dialogContentStyle,
                ),
                const SizedBox(height: UIConstants.spacingM),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: UIStyles.formInputDecoration.copyWith(
                    labelText: 'Passwort',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  enabled: !_isLoading,
                  style: UIStyles.dialogContentStyle,
                  onSubmitted: (_) => _handleLogin(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            mainAxisAlignment: UIConstants.spaceBetweenAlignment,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: UIStyles.dialogCancelButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(Icons.close, color: UIConstants.closeIcon),
                      const SizedBox(width: UIConstants.spacingS),
                      ScaledText(
                        'Abbrechen',
                        style: UIStyles.dialogButtonTextStyle.copyWith(
                          color: UIConstants.cancelButtonText,
                          fontSize: UIConstants.buttonFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              UIConstants.horizontalSpacingM,
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: UIStyles.dialogAcceptButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(Icons.login, color: UIConstants.checkIcon),
                      const SizedBox(width: UIConstants.spacingS),
                      _isLoading
                          ? const SizedBox(
                            width: UIConstants.loadingIndicatorSize,
                            height: UIConstants.loadingIndicatorSize,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                UIConstants.defaultAppColor,
                              ),
                            ),
                          )
                          : ScaledText(
                            'Login',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.submitButtonText,
                              fontSize: UIConstants.buttonFontSize,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
