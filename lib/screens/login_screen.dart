// Project: Mein BSSB
// Filename: login_screen.dart
// Author: Luis Mandel / NTT DATA

// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/registration_screen.dart';
import '/screens/password_reset_screen.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '/services/api_service.dart';
import '/services/core/email_service.dart';
import '/services/core/logger_service.dart';
import '/services/core/font_size_provider.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onLoginSuccess,
    this.logoWidget,
    super.key,
  });
  final Function(UserData) onLoginSuccess;
  final Widget? logoWidget;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  static const double _menuIconSize = 24.0;
  static const double _menuIconPadding = 8.0;
  static const double _menuIconSpacing = 16.0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final Color _appColor = UIConstants.defaultAppColor;
  UserData? _userData;
  bool _isLoggedIn = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeState();
  }

  Future<void> _loadRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('savedEmail') ?? '';
        _passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  Future<void> _saveRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text);
      await prefs.setString('savedPassword', _passwordController.text);
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      LoggerService.logInfo('Login response: $response');

      if (response['ResultType'] == 1) {
        await _saveRememberMeState();
        await _handleSuccessfulLogin(
          apiService,
          response['PersonID'],
          response['WebLoginID'],
        );
      } else {
        setState(() => _errorMessage = response['ResultMessage']);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSuccessfulLogin(
    ApiService apiService,
    int personId,
    int webloginId,
  ) async {
    LoggerService.logInfo('Retrieving passdaten');
    var passdaten = await apiService.fetchPassdaten(personId);
    LoggerService.logInfo('User data: $passdaten');

    if (!mounted) return;

    if (passdaten != null) {
      _userData = passdaten.copyWith(webLoginId: webloginId);
      _isLoggedIn = true;
      widget.onLoginSuccess(_userData!);

      await apiService.fetchSchuetzenausweis(personId);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {'userData': _userData!.toJson(), 'isLoggedIn': true},
        );
      }
    } else {
      setState(() => _errorMessage = 'Fehler beim Laden der Passdaten.');
    }
  }

  void _navigateToRegistrationPage() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final emailService = Provider.of<EmailService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(
          authService: authService,
          emailService: emailService,
        ),
      ),
    );
  }

  Future<void> _navigateToPasswordReset() async {
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordResetScreen(
          authService: authService,
          userData: _userData,
          isLoggedIn: _isLoggedIn,
          onLogout: _handleLogout,
        ),
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Widget _buildEmailField() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return TextField(
          key: const Key('usernameField'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: UIStyles.bodyStyle.copyWith(
            fontSize:
                UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
          ),
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: 'E-mail',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: UIStyles.formLabelStyle.copyWith(
              fontSize: UIStyles.formLabelStyle.fontSize! *
                  fontSizeProvider.scaleFactor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return TextField(
          key: const Key('passwordField'),
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: UIStyles.bodyStyle.copyWith(
            fontSize:
                UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
          ),
          decoration: UIStyles.formInputDecoration.copyWith(
            labelText: 'Passwort',
            labelStyle: UIStyles.formLabelStyle.copyWith(
              fontSize: UIStyles.formLabelStyle.fontSize! *
                  fontSizeProvider.scaleFactor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                }
              },
            ),
          ),
          onSubmitted: (value) => _handleLogin(),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key('loginButton'),
        onPressed: _isLoading ? null : _handleLogin,
        style: UIStyles.defaultButtonStyle,
        child: SizedBox(
          height: 36, // Match the minimumSize height from defaultButtonStyle
          child: Center(
            child: _isLoading
                ? UIConstants.defaultLoadingIndicator
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, color: Colors.white),
                      SizedBox(width: UIConstants.spacingS),
                      ScaledText(
                        UIConstants.loginButtonLabel,
                        style: UIStyles.buttonStyle,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      key: const Key('forgotPasswordButton'),
      onPressed: _navigateToPasswordReset,
      style: UIStyles.textButtonStyle,
      child: const ScaledText(
        UIConstants.forgotPasswordLabel,
        style: UIStyles.linkStyle,
      ),
    );
  }

  Widget _buildHelpButton() {
    return TextButton(
      key: const Key('helpButton'),
      onPressed: () {
        Navigator.pushNamed(context, '/help');
      },
      style: UIStyles.textButtonStyle,
      child: const ScaledText(
        UIConstants.helpTitle,
        style: UIStyles.linkStyle,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
      key: const Key('registerButton'),
      onPressed: _navigateToRegistrationPage,
      style: UIStyles.textButtonStyle,
      child: const ScaledText(
        UIConstants.registerButtonLabel,
        style: UIStyles.linkStyle,
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (bool? value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: _appColor,
        ),
        const ScaledText(
          'Angemeldet bleiben',
          style: UIStyles.bodyStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highContrastColor =
        theme.brightness == Brightness.dark ? Colors.amber : Colors.blue;

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.logoWidget ?? const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            ScaledText(
              UIConstants.loginTitle,
              style: UIStyles.headerStyle.copyWith(
                color: _appColor,
              ),
            ),
            const SizedBox(height: UIConstants.spacingS),
            if (_errorMessage.isNotEmpty)
              ScaledText(
                _errorMessage,
                style: UIStyles.errorStyle,
              ),
            const SizedBox(height: UIConstants.spacingM),
            _buildEmailField(),
            const SizedBox(height: UIConstants.spacingS),
            _buildPasswordField(),
            const SizedBox(height: UIConstants.spacingS),
            _buildRememberMeCheckbox(),
            const SizedBox(height: UIConstants.spacingM),
            _buildLoginButton(),
            const SizedBox(height: UIConstants.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildForgotPasswordButton(),
                _buildHelpButton(),
              ],
            ),
            const SizedBox(height: UIConstants.spacingS),
            Center(
              child: _buildRegisterButton(),
            ),
          ],
        ),
      ),
    );
  }
}
