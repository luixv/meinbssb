import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/services/api/auth_service.dart';
import '/services/core/font_size_provider.dart';
import '/widgets/scaled_text.dart';

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
      Provider.of<AuthService>(context, listen: false);
      // TODO: Implement password change logic with authService

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwort erfolgreich geändert'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Ändern des Passworts: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte geben Sie ein Passwort ein';
    }
    if (value.length < 8) {
      return 'Das Passwort muss mindestens 8 Zeichen lang sein';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Das Passwort muss mindestens einen Großbuchstaben enthalten';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Das Passwort muss mindestens einen Kleinbuchstaben enthalten';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Das Passwort muss mindestens eine Zahl enthalten';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Das Passwort muss mindestens ein Sonderzeichen enthalten';
    }
    return null;
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
                      padding:
                          const EdgeInsets.only(bottom: UIConstants.spacingM),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              )
            : const Icon(Icons.save, color: Colors.white),
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
            color: UIConstants.defaultAppColor,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
