import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/change_password_success_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double _strength = 0;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final personId = widget.userData?.personId;
      final apiService = Provider.of<ApiService>(context, listen: false);
      final cacheService = Provider.of<CacheService>(context, listen: false);

      if (personId == null) {
        throw Exception(Messages.personIdMissing);
      }

      // Get username from cache
      final username = await cacheService.getString('username');
      if (username == null) {
        throw Exception(Messages.usernameNotFound);
      }

      // First, validate the current password
      final loginResponse = await apiService.login(
        username,
        _currentPasswordController.text,
      );

      if (loginResponse['ResultType'] != 1) {
        if (!mounted) return;
        _showPasswordIncorrectSnackbar();
        return;
      }

      // If current password is valid, proceed with password change
      final result = await apiService.myBSSBPasswortAendern(
        personId,
        _newPasswordController.text,
      );

      if (!mounted) return;
      _navigateToResultScreen(result['result'] == true);
    } catch (e) {
      if (!mounted) return;
      _navigateToResultScreen(false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPasswordIncorrectSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(Messages.currentPasswordIncorrect),
        backgroundColor: UIConstants.errorColor,
      ),
    );
  }

  void _navigateToResultScreen(bool success) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangePasswordSuccessScreen(
          success: success,
          userData: widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
    if (value.length < 8) return 'Mindestens 8 Zeichen';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Mind. 1 Großbuchstabe';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Mind. 1 Kleinbuchstabe';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mind. 1 Zahl';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Mind. 1 Sonderzeichen';
    }
    return null;
  }

  void _checkStrength(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[a-z]').hasMatch(value)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.15;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) strength += 0.2;
    setState(() => _strength = strength);
  }

  String _strengthLabel(double value) {
    if (value < 0.4) return 'Schwach';
    if (value < 0.7) return 'Mittel';
    return 'Stark';
  }

  Color _strengthColor(double value) {
    if (value < 0.4) return UIConstants.errorColor;
    if (value < 0.7) return UIConstants.warningColor;
    return UIConstants.successColor;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Neues Passwort erstellen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: true,
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) {
          return SingleChildScrollView(
            padding: UIConstants.defaultPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: UIConstants.spacingM,
                      ),
                      child: ScaledText(
                        _errorMessage!,
                        style: UIStyles.errorStyle.copyWith(
                          fontSize: UIStyles.errorStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                    ),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Aktuelles Passwort',
                    isVisible: _isCurrentPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie Ihr aktuelles Passwort ein';
                      }
                      return null;
                    },
                    fontSizeProvider: fontSizeProvider,
                    eyeIconColor: UIConstants.textColor,
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Neues Passwort',
                    isVisible: _isNewPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                    validator: _validatePassword,
                    fontSizeProvider: fontSizeProvider,
                    eyeIconColor: UIConstants.textColor,
                    onChanged: _checkStrength,
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 4.0, bottom: UIConstants.spacingS),
                    child: ScaledText(
                      'Mindestens 8 Zeichen, 1 Großbuchstabe, 1 Kleinbuchstabe, 1 Zahl, 1 Sonderzeichen',
                      style: UIStyles.formLabelStyle,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _strength,
                          minHeight: 6,
                          backgroundColor: UIConstants.greySubtitleTextColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _strengthColor(_strength),
                          ),
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingS),
                      ScaledText(
                        _strengthLabel(_strength),
                        style: UIStyles.bodyStyle
                            .copyWith(color: _strengthColor(_strength)),
                      ),
                    ],
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Neues Passwort wiederholen',
                    isVisible: _isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte wiederholen Sie das neue Passwort';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Die Passwörter stimmen nicht überein';
                      }
                      return null;
                    },
                    fontSizeProvider: fontSizeProvider,
                    eyeIconColor: UIConstants.textColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'save_password',
        onPressed: _isLoading ? null : _handleSave,
        backgroundColor: UIConstants.defaultAppColor,
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(UIConstants.whiteColor),
                strokeWidth: UIConstants.defaultStrokeWidth,
              )
            : const Icon(Icons.save, color: UIConstants.whiteColor),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required FontSizeProvider fontSizeProvider,
    String? Function(String?)? validator,
    Color eyeIconColor = UIConstants.defaultAppColor,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: UIStyles.formValueStyle.copyWith(
        fontSize:
            UIStyles.formValueStyle.fontSize! * fontSizeProvider.scaleFactor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: UIStyles.formInputDecoration.labelStyle?.copyWith(
          fontSize: UIStyles.formInputDecoration.labelStyle!.fontSize! *
              fontSizeProvider.scaleFactor,
        ),
        floatingLabelStyle:
            UIStyles.formInputDecoration.floatingLabelStyle?.copyWith(
          fontSize: UIStyles.formInputDecoration.floatingLabelStyle!.fontSize! *
              fontSizeProvider.scaleFactor,
        ),
        errorStyle: UIStyles.errorStyle.copyWith(
          fontSize:
              UIStyles.errorStyle.fontSize! * fontSizeProvider.scaleFactor,
        ),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: eyeIconColor,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
