// Project: Mein BSSB
// Filename: login_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/registration_screen.dart';
import '/screens/help_screen.dart';
import '/screens/password_reset_screen.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '/services/api_service.dart';
import '/services/core/email_service.dart';
import '/services/core/logger_service.dart';
import '/models/user_data.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final Color _appColor = UIConstants.defaultAppColor;
  UserData? _userData;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
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
    return TextField(
      key: const Key('usernameField'),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'E-mail',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      key: const Key('passwordField'),
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: UIStyles.formInputDecoration.copyWith(
        labelText: 'Passwort',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            if (mounted) {
              //check mounted before calling setState
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            }
          },
        ),
      ),
      onSubmitted: (value) => _handleLogin(),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const Key(
          'loginButton',
        ), // Name of the button, used for the integration test
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: UIConstants.submitButtonBackground,
          padding: UIConstants.buttonPadding,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  UIConstants.circularProgressIndicator,
                ),
              )
            : const Text(
                'Anmelden',
                style: TextStyle(
                  fontSize: UIConstants.bodyFontSize,
                  color: UIConstants.submitButtonText,
                ),
              ),
      ),
    );
  }

  Widget _buildNavigationLinks() {
    return Center(
      child: Column(
        children: [
          TextButton(
            onPressed: _navigateToPasswordReset,
            child: Text(
              'Passwort vergessen?',
              style: UIStyles.linkStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Noch kein Konto?',
                  style: UIStyles.bodyStyle.copyWith(
                    fontSize: UIConstants.subtitleFontSize,
                  ),
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: _navigateToRegistrationPage,
                  child: Text(
                    'Registrieren',
                    style: UIStyles.linkStyle.copyWith(
                      fontSize: UIConstants.subtitleFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelpScreen(
                    userData: _userData,
                    isLoggedIn: _isLoggedIn,
                    onLogout: _handleLogout,
                  ),
                ),
              );
            },
            child: Text(
              'Hilfe',
              style: UIStyles.linkStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hier wird die Hintergrundfarbe des Scaffolds geändert.
      backgroundColor: UIConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.logoWidget ?? const LogoWidget(),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              'Hier anmelden',
              style: UIStyles.headerStyle.copyWith(color: _appColor),
            ),
            const SizedBox(height: UIConstants.spacingS),
            _buildEmailField(),
            const SizedBox(height: UIConstants.spacingS),
            _buildPasswordField(),
            const SizedBox(height: UIConstants.spacingS * 2),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: UIStyles.errorStyle),
            _buildLoginButton(),
            const SizedBox(height: UIConstants.spacingS),
            _buildNavigationLinks(),
          ],
        ),
      ),
    );
  }
}
