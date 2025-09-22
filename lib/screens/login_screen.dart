import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/screens/registration_screen.dart';
import 'package:meinbssb/screens/password_reset_screen.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

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
  bool _rememberMe = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initRememberMe();
  }

  Future<void> _initRememberMe() async {
    await _loadRememberMeState();
    if (_rememberMe) {
      await _loadStoredCredentials();
    }
  }

  Future<void> _loadRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('rememberMe') ?? false;
  }

  Future<void> _loadStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final savedPassword = await _secureStorage.read(key: 'password');

    setState(() {
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
      if (savedPassword != null && savedPassword.isNotEmpty) {
        _passwordController.text = savedPassword;
      }
    });
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

    // Save remember me state before attempting login
    await _saveRememberMeState();

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
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'userData': _userData!.toJson(), 'isLoggedIn': true},
      );
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
    final apiService = Provider.of<ApiService>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordResetScreen(
          apiService: apiService,
          userData: _userData,
          isLoggedIn: _isLoggedIn,
          onLogout: _handleLogout,
        ),
      ),
    );
  }

  void _handleLogout() async {
    // Clear stored credentials when logging out
    await _clearStoredCredentials();

    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });
    // Navigation is handled by the app's logout handler
  }

  Future<void> _saveRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text);
      // Save password to secure storage immediately when remember me is enabled
      await _secureStorage.write(
        key: 'password',
        value: _passwordController.text,
      );
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('savedEmail');
      // Clear password from secure storage when "remember me" is disabled
      await _secureStorage.delete(key: 'password');
    }
  }

  Future<void> _clearStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('savedEmail');
    await _secureStorage.delete(key: 'password');
  }

  Widget _buildEmailField() {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return TextField(
          key: const Key('usernameField'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enableInteractiveSelection: true,
          enableSuggestions: true,
          autocorrect: false,
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
          height: UIConstants
              .defaultButtonHeight, // Match the minimumSize height from defaultButtonStyle
          child: Center(
            child: _isLoading
                ? UIConstants.defaultLoadingIndicator
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, color: UIConstants.whiteColor),
                      SizedBox(width: UIConstants.spacingS),
                      ScaledText(
                        Messages.loginButtonLabel,
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
        Messages.forgotPasswordLabel,
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
        Messages.helpTitle,
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
        Messages.registerButtonLabel,
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
    Theme.of(context);

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: UIConstants.screenPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.logoWidget ?? const LogoWidget(),
                  const SizedBox(height: UIConstants.spacingS),
                  ScaledText(
                    Messages.loginTitle,
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
          ),
        ),
      ),
    );
  }
}
