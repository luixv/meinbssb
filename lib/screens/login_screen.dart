// Project: Mein BSSB
// Filename: login_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/registration_screen.dart';
import '/screens/help_screen.dart';
import '/screens/password_reset_screen.dart';
import '/screens/logo_widget.dart';
import '/services/api/auth_service.dart';
import '/services/api_service.dart';
import '/services/email_service.dart';
import '/services/logger_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLoginSuccess, super.key});
  final Function(Map<String, dynamic>) onLoginSuccess;

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
  Map<String, dynamic> _userData = {};
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
        await _handleSuccessfulLogin(apiService, response['PersonID']);
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
  ) async {
    LoggerService.logInfo('Retrieving passdaten');
    var passdaten = await apiService.fetchPassdaten(personId);
    LoggerService.logInfo('User data: $passdaten');

    if (!mounted) return;

    if (passdaten.isNotEmpty) {
      final completeUserData = {...passdaten, 'PERSONID': personId};
      _userData = completeUserData;
      _isLoggedIn =
          true; // Update the login state.  Crucial for passing to PasswordReset.
      widget.onLoginSuccess(completeUserData);

      await apiService.fetchSchuetzenausweis(personId);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {'userData': completeUserData, 'isLoggedIn': true},
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
        builder:
            (context) => RegistrationScreen(
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
        builder:
            (context) => PasswordResetScreen(
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
      _isLoggedIn = false; //  Update local state.
      _userData = {};
    });
    Navigator.of(context).pushReplacementNamed(
      '/login',
    ); // Navigate back to login.  Use pushReplacementNamed
  }

  Widget _buildEmailField() {
    return TextField(
      key: const Key('usernameField'), // Use const for keys
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: UIConstants.defaultInputDecoration.copyWith(
        labelText: 'E-mail',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      key: const Key('passwordField'),
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: UIConstants.defaultInputDecoration.copyWith(
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
          backgroundColor: UIConstants.lightGreen,
          padding: UIConstants.buttonPadding,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  color: UIConstants.white,
                  strokeWidth: 2.0,
                )
                : Text(
                  'Anmelden',
                  style: UIConstants.bodyStyle.copyWith(
                    color: UIConstants.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildNavigationLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: _navigateToPasswordReset,
          child: Text(
            'Passwort vergessen?',
            style: UIConstants.linkStyle.copyWith(
              color: _appColor,
              fontSize: UIConstants.subtitleFontSize,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Noch kein Konto?',
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            TextButton(
              onPressed: _navigateToRegistrationPage,
              child: Text(
                'Registrieren',
                style: UIConstants.linkStyle.copyWith(
                  color: _appColor,
                  fontSize: UIConstants.subtitleFontSize,
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
                builder:
                    (context) => HelpScreen(
                      userData: _userData,
                      isLoggedIn: _isLoggedIn,
                      onLogout: _handleLogout,
                    ),
              ),
            );
          },
          child: Text(
            'Hilfe',
            style: UIConstants.linkStyle.copyWith(
              color: _appColor,
              fontSize: UIConstants.subtitleFontSize,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Hier anmelden',
              style: UIConstants.headerStyle.copyWith(color: _appColor),
            ),
            SizedBox(height: UIConstants.defaultSpacing),
            _buildEmailField(),
            SizedBox(height: UIConstants.smallSpacing),
            _buildPasswordField(),
            SizedBox(height: UIConstants.defaultSpacing * 2),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: UIConstants.errorStyle),
            _buildLoginButton(),
            SizedBox(height: UIConstants.defaultSpacing),
            _buildNavigationLinks(),
          ],
        ),
      ),
    );
  }
}
